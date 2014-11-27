
#include "vxWorks.h"
#include "config.h"
#include "vmLib.h"
#include "cacheLib.h"
#include <drv/pci/pciConfigLib.h>
#include "stdio.h"
#include "string.h"
#include "taskLib.h"
//#include "spi_map.h"
/*#include "mcp2515.h"
#include "can.h"
#include "mcp2515_bittime.h"
#include "mcp2515_defs.h"

#include "mcp2515.c"*/

#include "httpdsimple.c"

#define plxdebug

#define DMAWAS       0x0
#define DMAWAD_L     0x4
#define DMAWAD_U     0x8
#define DMARAS_L     0xc
#define DMARAS_U     0x10
#define DMARAD       0x14
#define DMAWXS       0x18
#define DMARXS       0x1c
#define DMACST       0x28
#define DMAUST       0x38

#define PCIBAR1WSTS  0x1ffffc
#define PCIBAR1WDATA 0x1ffff8
#define DIREG        0x80000
#define DOREG        0x80004
#define DENREG       0x80008

#define DMAWSTART    (1 << 0)
#define DMAWCOMPE    (1 << 1)
#define DMARSTART    (1 << 2)
#define DMARCOMPE    (1 << 3)
#define DMAWFINISH   (1 << 4)
#define DMARFINISH   (1 << 5)

#define DMAUSTRECORD	(1 << 0)
#define DMAUSTSIM		(1 << 2)


#define THR          0x0
#define RHR          0x0
#define DLL          0x0
#define DLH          0x4
#define FCR          0x8
#define FCR_ENABLE_STS (3 << 6)
#define FCR_ENABLE (1 << 0)
#define LCR          0xc
#define MCR          0x10
#define LSR          0x14
#define MSR          0x18
#define TFL           0x80
#define RFL           0x84

#define LSR_THRE       (1 << 5)
#define LSR_DR         (1 << 0)

#define LCR_DLAB       (1 << 7)
#define LCR_STOP_1BIT  (0 << 2)
#define LCR_STOP_15BIT (1 << 2)
#define LCR_DATA_5BIT  (0 << 0)
#define LCR_DATA_6BIT  (1 << 0)
#define LCR_DATA_7BIT  (2 << 0)
#define LCR_DATA_8BIT  (3 << 0)
#define UARTTIMEOUT    0x8000

#define FGPACLK_INPUT  100000000
#define SIONUM          15
UINT32   addr0,addr1,addr2,addr3,sioRevFlag;
UINT32 sioBase[SIONUM] = {0x100000,0x104000,0x108000,0x140000,
						  0x144000,0x148000,0x14c000,0x150000,
						  0x180000,0x184000,0x188000,0x18c000,
						  0x190000,0x194000,0x198000};
#define SWAP_LE_BE(x) ((x>>24)|((x>>8)&0xff00)|((x<<24))|((x<<8)&0xff0000))
#define WORD_SWAP(x) (((x)>>8) | (((x)<<8)&0xff00))
#define UARTREGOFFSET(x,y) (sioBase(x) + (y << 2))
#define PLX_VENDOR_ID603   0x10ee
#define PLX_DEVICE_ID603   0x0007

#define SPIBARREAD(offset) (pciBar1RegR(SPIBASE + offset))
#define SPIBARWRITE(offset,value) (pciBar1RegW(SPIBASE + offset,value))

#define uint8_t UINT8
/*#define SPICTRL0       0x0
#define SPICTRL1       0x4
#define SPISSIEN       0x8
#define SPIMWCR        0xC
#define SPISER         0x10
#define SPIBAUDR       0x14
#define SPITXFTLR      0x18*/

#define AD_0_BASE      0x70000
#define AD_1_BASE      0x71000

#define ad_cha_base_addr0            0x00000018 /* type = RW, reset_val = 0 */
#define ad_cha_base_addr1            0x0000001c /* type = RW, reset_val = 0 */
#define ad_chb_base_addr0            0x00000020 /* type = RW, reset_val = 0 */
#define ad_chb_base_addr1            0x00000024 /* type = RW, reset_val = 0 */
#define ad_ch_len                    0x00000038 /* type = RW, reset_val = 0x400 */
#define ad_start                     0x00000040 /* type = WT, reset_val = 0x0 */
#define ad_done                      0x00000044 /* type = WT, reset_val = 0x0 */
#define ad_done_st                   0x00000048 /* type = RD, reset_val = 0x0 */
#define ad_done_st_bit               (1 << 0)

//IMPORT int memSysPartId;
//IMPORT void	vxMsrSet (UINT32);  
//IMPORT UINT32	vxMsrGet (void);
//IMPORT void vxbUsDelay(int	delayTime);

void MCP2515_SELECT(void);
void MCP2515_UNSELECT(void);

/*#include "mcp2515.c"
#include "can.c"*/


#include "analyzer.h"

////////////////////////////////////////////////////////////////////
UINT32 pciBar0Read(UINT32 offset);
void pciDmaR    (    UINT32 src,    UINT32 dst,    UINT32 len    );

void pciVideoTest(void)
{
	int i;
	
	//包计数
	DWORD dwPackCnts = 0;
	//帧错误即帧序号不连续计数
	DWORD dwPackFrmErrCnts = 0;
	
	DWORD dwPrintCnts = 0;
	
	DWORD dwDmaStatus;
	BYTE * byaDmaData;
	BYTE * byaDmaDataPhy;
	DWORD dwDmaDataSize;
	
	//解包后的包数据
	BYTE *pbyPackData;
	//解包后的包长度
	DWORD dwPackSize;
	
	//图像通道
	DWORD  dwCh;
	
	DWORD dwRet;
	
	//从数据包中得到帧序号
	DWORD dwIndexCalc = 0;
	//本地的帧序号
	DWORD dwIndex = 0;
	//接到的第一包
	DWORD dwIndexFirst = 1;
	
	//申请内存
	byaDmaData = memPartAlignedAlloc(memSysPartId, ANALYZER_READ_MAX, 0x1000);
	byaDmaDataPhy = CACHE_DMA_VIRT_TO_PHYS (byaDmaData);	
	//规定DMA默认值为2K
	dwDmaDataSize = 2*1024;
	
	pbyPackData = malloc(ANALYZER_PACKBUFFER_MAX);
	dwPackSize = 0;
	
	//pcie初始化
	pciInit();
	
	//解包程序初始化
	anaReset();
	
	printf("start : byaDmaData 0x%08x byaDmaDataPhy 0x%08x\n", byaDmaData,byaDmaDataPhy);
	//注意add0 add1 是在pciInit()中初始化的，对应子板的PCIE地址
	//如果存在多块卡，请注意区分不同板子的add0 add1
	printf("addr0 0x%8x, addr1 0x%08x\n", addr0, addr1);

while(1)
{
	taskDelay(10);
	//等待0x40寄存器返回压缩子板的数据量
	do{
		dwDmaStatus = pciBar0Read(0x40);
		//printf("dwDmaStatus is %d\n", dwDmaStatus);
	}while (dwDmaStatus < dwDmaDataSize);//超过2K则开始一次DMA之旅
	
	//printf("dwDmaStatus is %d\n", dwDmaStatus);
	
	//注意此处使用pciDmaW函数读取数据，这是按照DMA使用手册的定义来的
	//如果为了避免歧义请自行修改函数定义
	pciDmaW(0, (DWORD)byaDmaDataPhy, dwDmaDataSize);

	while(1)
	{
		//解析数据
		if(anaParse(byaDmaData, dwDmaDataSize, pbyPackData, &dwPackSize) == 0)
		{
			break;
		}
		
		//得到正确的一包，开始分析
		dwCh = getWordFromByte(pbyPackData + 2);
		if(dwCh == 0 )
		{
			dwIndexCalc = getDwordFromByte(pbyPackData + 4);
			if (dwIndexFirst == 1)
			{
				dwIndexFirst = 0;
			}
			else
			{
				dwIndex++;
				if(dwIndexCalc != dwIndex)
				{	
					dwPackFrmErrCnts++;
					printf("dwIndexCalc %d, dwIndex %d\n",dwIndexCalc, dwIndex);
				}
			}	
			dwIndex = dwIndexCalc;
			
			dwPackCnts++;
			//仅仅复制有效数据进缓冲
			dwRet = FIFOWrite(&g_fifo, pbyPackData+12,dwPackSize-16);
		}
		
		if ((dwPrintCnts++%10) == 0)
		{
			printf("dwPackCnts is %8d, dwPackFrmErrCnts is %8d\r", dwPackCnts, dwPackFrmErrCnts);
		}		
	}
}
}

void pciInit(void)
{
    STATUS          result;
    int             i=0;

    int             busNo, devNo, funcNo;
    int             index_603=0,index_601=0;
    UINT8           irq;
    UINT32 stsRegValue = 0;
    
    DWORD dwRet;
    
    /*检索SCU A/B*/
    for(i=0;i<7;i++)
    { 
        /* search for devices with PLX9050 PCI controller */
        result = pciFindDevice(PLX_VENDOR_ID603, PLX_DEVICE_ID603, i, &busNo, &devNo, &funcNo);
        
        if (result == OK) 
        {
                  
                #ifdef plxdebug
                   printf("find 6bu board at bus=%x,devno=%x,funcno=%x\n",busNo,devNo,funcNo);
                #endif               
                pciConfigInLong(busNo, devNo, funcNo, PCI_CFG_BASE_ADDRESS_0, &addr0);
                addr0 &= PCI_MEMBASE_MASK;
                #ifdef plxdebug
                   printf("the addr0 is %x\n",addr0);
                #endif   
                pciConfigInLong(busNo, devNo, funcNo, PCI_CFG_BASE_ADDRESS_1, &addr1);
                #ifdef plxdebug
                   printf("the addr1 is %x\n",addr1);
                #endif   
                addr2 &= PCI_MEMBASE_MASK;
                pciConfigInByte (busNo, devNo, funcNo,PCI_CFG_DEV_INT_LINE,&irq);          
                #ifdef plxdebug
                   printf("the irq is %x\n",irq);
                #endif   

                /* enable PCI target memory and I/O cycles. */
            /*    pciConfigOutWord (busNo, devNo, funcNo, PCI_CFG_COMMAND, 
                    PCI_CMD_IO_ENABLE | PCI_CMD_MEM_ENABLE | PCI_CMD_MASTER_ENABLE);*/
            }        
    }
    //pciBar1SdramInit();
    
  /*  stsRegValue = pciBar0Read(DMAUST);
    stsRegValue = stsRegValue | DMAUSTRECORD | DMAUSTSIM;
    pciBar0Write(DMAUST,stsRegValue);*/
    
  /*  sioInit();*/
    
    printf("addr0 0x%8x, addr1 0x%08x\n", addr0, addr1);
    
    for(i=0;i<=0x40;i+=4)
    {
    	dwRet = pciBar0Read(i);
		printf("%02d(0x%02x) : dwRet is 0x%8x\n", i, i, dwRet);
    }
    
}

UINT32 pciBar0Read
    (
    UINT32 offset		
    )
    {
    UINT32 dataValue = 0;
    dataValue = *(volatile UINT32 *)(addr0 + offset);
   /* printf("dataValue == %x\n",dataValue);*/
	dataValue = SWAP_LE_BE(dataValue);
/*	printf("SWAP dataValue == %x\n",dataValue);*/
	return (dataValue);
    }
void pciBar0Write
    (
    UINT32 offset,
    UINT32 value
    )
   {
   value = SWAP_LE_BE(value);	
  /* printf("SWAP write value == %x\n",value);*/
   *(volatile UINT32 *)(addr0 + offset) = value;
   }	

UINT32 pciBar1Read
    (
    UINT32 offset   		   
    )
    {
    UINT32 dataValue = 0;
    UINT32 dataTemp = 0;
    dataValue = *(volatile UINT32 *)(addr1 + offset);
/*    printf("dataValue == %x\n",dataValue);*/
    dataTemp = SWAP_LE_BE(dataValue);
/*	printf("SWAP dataValue == %x\n",dataValue);	*/
    return (dataTemp);
    }
void pciBar1Write
    (
    UINT32 offset,
    UINT32 value
    )
   {
   value = SWAP_LE_BE(value);	
  /* printf("SWAP write value == %x\n",value);*/
   *(volatile UINT32 *)(addr1 + offset) = value;
   }
void pciBar1RegW
    (
    UINT32 offset,
    UINT32 value
    )
    {
	UINT32 stsReg = 0;
	UINT32 timeOut = 0x8000;
	pciBar1Write(offset,value);
	stsReg = pciBar1Read(PCIBAR1WSTS);
  //vxbUsDelay(1000); 
	while(((stsReg & 0x01) != 0x0) && (timeOut > 0))
	    {
		timeOut--;
		stsReg = pciBar1Read(PCIBAR1WSTS);
	    }
    }
UINT32 pciBar1RegR
    (
    UINT32 offset
    )
    {
	UINT32 stsReg = 0;
    UINT32 regValue = 0;
	UINT32 timeOut = 0x8000;
	pciBar1Read(offset);
	stsReg = pciBar1Read(PCIBAR1WSTS);
  //vxbUsDelay(1000); 
	while(((stsReg & 0x01) != 0x0) && (timeOut > 0))
	    {
		timeOut--;
		stsReg = pciBar1Read(PCIBAR1WSTS);
	    }
	regValue = pciBar1Read(PCIBAR1WDATA);
/*	printf("regValue == %x\n",regValue);*/
    return (regValue);
    }

void pciDmaW
    (
    UINT32 src,
    UINT32 dst,
    UINT32 len
    )
    {
    UINT32 stsRegValue = 0;
    UINT32 timeOut = 0x50000;
    
	pciBar0Write(DMAWAS,0x0);//@@mal
	pciBar0Write(DMAWAD_L,dst);	
	pciBar0Write(DMAWAD_U,dst);	
	pciBar0Write(DMAWXS,len);	
	/*stsRegValue = pciBar0Read(DMACST);*/
	stsRegValue = DMAWSTART;
	pciBar0Write(DMACST,stsRegValue);
#if 0
	pciBar1RegW(0x84,0x1);
	pciBar1RegW(0x4,src);//@@mal
	pciBar1RegW(0x18,(len >> 3));
	pciBar1RegW(0x14,0x1);
#endif
	stsRegValue = pciBar0Read(DMACST);
	while(((stsRegValue & DMAWCOMPE) == 0x0) && (timeOut > 0))
	    {
		stsRegValue = pciBar0Read(DMACST);
	/*	printf("dmaW stsRegValue == %x\n",stsRegValue);*/
		timeOut--;
	    }	
	//pciBar0Write(DMACST,DMAWCOMPE | DMAWFINISH);	//DMAWFINISH can't set
	pciBar0Write(DMACST,DMAWCOMPE);
	CACHE_DMA_INVALIDATE(dst,0x1000);
	/*	stsRegValue = pciBar1RegR(0x44);
	if(stsRegValue != len)
		printf("ERROR : stsRegValue != len and stsRegValue = %x\n",stsRegValue);
	stsRegValue = pciBar1RegR(0x1C);
	if(stsRegValue != 0x0)
		printf("ERROR : stsRegValue != 0x0 and stsRegValue = %x\n",stsRegValue);*/
    }
void pciDmaR
    (
    UINT32 src,
    UINT32 dst,
    UINT32 len
    )
    {
    UINT32 stsRegValue = 0;
    UINT32 timeOut = 0x50000;
	CACHE_DMA_FLUSH(src,0x1000);
    pciBar0Write(DMARAD,0x0);
	pciBar0Write(DMARAS_L,src);	
	pciBar0Write(DMARAS_U,0x0);		
	pciBar0Write(DMARXS,len);	
#if 0
	pciBar1RegW(0x80,0x1);
	pciBar1RegW(0x0,dst);
	pciBar1RegW(0xc,(len >> 3));
	pciBar1RegW(0x8,0x1);
#endif
	stsRegValue = pciBar0Read(DMACST);
	stsRegValue |= DMARSTART;
	pciBar0Write(DMACST,stsRegValue);
	stsRegValue = pciBar0Read(DMACST);
	while(((stsRegValue & DMARCOMPE) == 0x0) && (timeOut > 0))
	    {
		stsRegValue = pciBar0Read(DMACST);
	/*	printf("dmaR stsRegValue == %x\n",stsRegValue);*/
		timeOut--;
	    }	
	//pciBar0Write(DMACST,DMARCOMPE | DMARFINISH);	//DMAWFINISH can't set
	pciBar0Write(DMACST,DMARCOMPE);
/*	stsRegValue = pciBar1RegR(0x40);
	if(stsRegValue != len)
		printf("ERROR : stsRegValue != len and stsRegValue = %x\n",stsRegValue);
	stsRegValue = pciBar1RegR(0x10);
	if(stsRegValue != 0x0)
		printf("ERROR : stsRegValue != 0x0 and stsRegValue = %x\n",stsRegValue);*/
    }
void dmaTest(UINT32 offset,int num, int len)
    {
	void * temp;
	void * temp2;
	int i = 0;
/*	temp = cacheDmaMalloc(0x200000);
	temp2 = cacheDmaMalloc(0x200000);*/
	temp = memPartAlignedAlloc(memSysPartId, 0x200000, 0x1000);
	temp2 = memPartAlignedAlloc(memSysPartId, 0x200000, 0x1000);
	temp = CACHE_DMA_VIRT_TO_PHYS (temp);	
	temp2 = CACHE_DMA_VIRT_TO_PHYS (temp2);	
/*	temp = memPartAlignedAllocInlined (memSysPartId, (UINT) 1024, 
						4096);
	temp2 = memPartAlignedAllocInlined (memSysPartId, (UINT) 1024, 
						4096);*/
	printf("temp adrs = 0x%x and temp2 adrs = 0x%x \n",temp,temp2);
	memset(temp,0xaa,0x100000);
/*	memset(temp,0x55,1024);*/
	/*for(i = 0; i < 0x20; i++)*/
	{
#if 1
	memset(temp2,0x55,0x100000);
/*	for(i = 0; i < 0x1000; i++)
	{
		*((UINT8 *)temp2 + i) = i;
	}
	printf("\n");*/
#endif
	//memset(temp2,0x55,4096);
	printf("begin pciDmaR \n");
	//pciBar1RegW(0xc,0x20);
	//pciBar1RegW(0x8,0x1);
	//modify by mal
	//pciDmaR((UINT32)temp,0x0,256);
	for(i = 0; i < num; i++)
	{
	    memset(temp,0xaa,0x400);
		pciDmaR((UINT32)temp2,offset,len);
	/*	taskDelay(60 * 15); */
	/*	printf("end pciDmaR cnt = %d \n",i);*/
		pciDmaW(offset,(UINT32)temp,len);
	    if (memcmp(temp,temp2,len-128)!= 0x0)
	    {
	    	printf("num error == %d and first data == \n",i /* ,(UINT16)*temp */);
	        
	    }
  /*  if ((i % 100) == 0x0)*/
    	
	}

	//printf("end pciDmaW \n");
	//memcpy(temp,temp2,0x2000);
	}
 /*   free (temp);
    free (temp2);*/
    }

void doDataSet
    (
    UINT32 diData
    )
    {
    UINT32 doData=0xffffffff;
    pciBar1RegW(DENREG,doData);
	pciBar1RegW(DOREG,diData);
    }

UINT32 diDataGet(void)
    {
    UINT32 diData=0x0;
    diData = pciBar1RegR(DIREG);
  /*  printf("di Data == %x\n",diData);*/
    return (diData);
    }	
void ditest()
{
UINT32 value=0;	
do
{
doDataSet(0xffffffff);
diDataGet();
if (((value++)%100000) == 0x0)
	printf("value == %x\n",value);
}while(1);
	
}
void pciBar1SdramInit()
    {
 /*   pciBar1RegW(0x10000,0x14c94100);*/
    pciBar1RegW(0x10004,0xeb2363);
    pciBar1RegW(0x10008,0x22);
    pciBar1RegW(0x80,1);
    pciBar1RegW(0x84,1);
    }
    
void sioInit(int channelNum)
    {
/*	pciBar1RegW(0x90000,0x01); 
	pciBar1RegW(0x94000,0x01);
	pciBar1RegW(0x98000,0x01);	
	pciBar1RegW(0x9c000,0x01);
	pciBar1RegW(0xa0000,0x01);*/
/*	pciBar1RegW((sioBase[channelNum] + (LCR << 2)), LCR_DLAB);
    pciBar1RegW((sioBase[channelNum] + (DLL << 2)), 0x8b);
    pciBar1RegW((sioBase[channelNum] + (DLH << 2)), 0x02);*/
	sioBaudSet(channelNum,9600);
    pciBar1RegW((sioBase[channelNum] + (LCR << 2)), 0x0);
    pciBar1RegW((sioBase[channelNum] + (LCR << 2)), LCR_DATA_8BIT);	
 	pciBar1RegW((sioBase[channelNum] + (FCR << 2)), 0xb1); 
    }
void sioDmaSet(UINT32 offset,int num, int len)
{
/*void * temp2;
temp2 = memPartAlignedAlloc(memSysPartId, 0x200000, 0x1000);
memset(temp2,0x55,4096);*/
	dmaTest(offset,num,len);	
/*pciDmaR((UINT32)temp2,0x0,4096);*/
pciBar1RegW((0x80000+0x398),0x1);	
pciBar1RegW((0x80000+0x58),0x0);	
pciBar1RegW((0x80000+0x00),0x100000|0x8000000);	
pciBar1RegW((0x80000+0x60),0x100000|0x8000000);	
pciBar1RegW((0x80000+0x08),0x2000);	
pciBar1RegW((0x80000+0x98),0x0);
pciBar1RegW((0x80000+0x40),0x400);
pciBar1RegW((0x80000+0x9c),0x884);
pciBar1RegW((0x80000+0x44),0x4);
pciBar1RegW((0x80000+0x70),0x00100921);
pciBar1RegW((0x80000+0x18),0x00200e21);
pciBar1RegW((0x80000+0x74),len);
pciBar1RegW((0x80000+0x1c),len);
pciBar1RegW((0x80000+0x3a0),0x00000303);
}
void sioBaudSet
    (
    int channelNum,
    UINT32 baud
    )
    {
    UINT32 lcrValue;
    UINT32 baudValue;	
    lcrValue = pciBar1RegR((sioBase[channelNum] + (LCR << 2)));
    lcrValue |= LCR_DLAB;
    pciBar1RegW((sioBase[channelNum] + (LCR << 2)), lcrValue);
 /*   switch(baud)
        {
        case 9600:
            pciBar1RegW((sioBase[channelNum] + (DLL << 2)), 0x8b);
            pciBar1RegW((sioBase[channelNum] + (DLH << 2)), 0x02);
            break;
        default:
        	  break;    
        }*/
    baudValue = (UINT32)((FGPACLK_INPUT)/(baud * 16));
    pciBar1RegW((sioBase[channelNum] + (DLL << 2)), (UINT8)(baudValue));
    pciBar1RegW((sioBase[channelNum] + (DLH << 2)), (UINT8)(baudValue >> 8));        
    lcrValue &= (~LCR_DLAB);    		
    pciBar1RegW((sioBase[channelNum] + (LCR << 2)), lcrValue);         
    }
void sioSend
    (
    int channelNum,
    UINT32 sendLen,
    UINT8 * pBuf
    )
    {
    UINT32 lsrValue = 0;
    UINT32 i = 0;
    UINT32 timeOut = 0;
    if (pBuf == NULL)
        return;
    lsrValue = pciBar1RegR((sioBase[channelNum] + (LSR << 2)));
    do
        {
        if ((lsrValue & LSR_THRE) != 0x0)
        	{
          pciBar1RegW((sioBase[channelNum] + (THR << 2)),*(pBuf + i));
          i++;
          timeOut = 0;
          }	  
        timeOut++;
        lsrValue = pciBar1RegR((sioBase[channelNum] + (LSR << 2)));
      /*  vxbUsDelay(1000);*/
    /*    taskDelay(3);*/
        } while((i < sendLen) && (timeOut < UARTTIMEOUT));	
    }
void sioSendDemo
    (
    int channelNum,
    UINT32 testNum
    )
    {
    UINT8 * pSendBuf;
    UINT32 msrValue;
    int i = 0;
    pSendBuf = malloc(testNum);
    if (pSendBuf == NULL)
        return;
  /* 	sioInit(channelNum);*/
    for(i = 0; i < testNum; i++)
        *(pSendBuf + i) = 0x30+i;   
    printf("i == %d\n",i);
    sioSend(channelNum,testNum,pSendBuf);
    }
void sioRev
    (
    int channelNum,
    UINT32 revLen,
    UINT8 * pBuf
    )
    {
    UINT32 lsrValue = 0;
    UINT32 i = 0;
    UINT32 timeOut = 0;
    if (pBuf == NULL)
        return;
    lsrValue = pciBar1RegR((sioBase[channelNum] + (LSR << 2)));
    do
        {
        if ((lsrValue & LSR_DR) != 0x0)
    	    {
          *(pBuf + i) = pciBar1RegR((sioBase[channelNum] + (RHR << 2)));
       /*   printf("revData = %x\n",*(pBuf + i));*/
          i++;
          }	  
        lsrValue = pciBar1RegR((sioBase[channelNum] + (LSR << 2)));
    /*    taskDelay(1);*/
        } while(i < revLen);	
    }    	    	    

void sioRevTest
    (
    int channelNum,
    UINT32 testNum
    )
    {
    UINT8 * pRevBuf;
    int i = 0;
    pRevBuf = malloc(testNum);
    if (pRevBuf == NULL)
        return;
    sioFifoRead(channelNum,testNum,pRevBuf);
    if (sioRevFlag == 5)
        sioSend(channelNum, testNum, pRevBuf);
    else
    	  for(i = 0; i < testNum; i++)
    	      printf("%c",*(pRevBuf + i));    
    }   
//
//void spiInit()
//    {
//    pciBar1RegW(0x88004,0x3);
//    pciBar1RegW(0x88008,0x3);
//		SPIBARWRITE(spiSSIENR,0x0);
//	SPIBARWRITE(spiCTRLR0, 0x0);
//	SPIBARWRITE(spiCTRLR0, 0xc7);
//	SPIBARWRITE(spiBAUDR, 200);
//	SPIBARWRITE(spiSSIENR,SPI_SSIENR_EN);
//    }
//
//void MCP2515_SELECT(void)
//    {
//	SPIBARWRITE(spiSER, 0x01);
//    }
//void MCP2515_UNSELECT(void)
//    {
//	SPIBARWRITE(spiSER, 0x00);
//    } 
//void spi_readwrite(UINT8 data)
//	{
//	SPIBARWRITE(spiDR, data);
//	/*	regValue = SPIBARREAD(spiSR);
//	do 
//		{
//        regValue = SPIBARREAD(spiSR);
//		}while((regValue & SPI_SR_BUSY) != 0x0); 
//	do
//		{
//              if((regValue & SPI_SR_RFNE) != 0x0)
//              	{
//                      printf("SR == %x\n",regValue);
//			 regValue = SPIBARREAD(spiDR);
//			 printf("DR == %x\n",regValue);
//			 return regValue;		 
//              	}	
//		regValue = SPIBARREAD(spiSR);
//		}while(1);*/
//       }
//
//void spi_writefinish(void)
//{
//UINT8 regValue = 0;
//	regValue = SPIBARREAD(spiSR);
//	do 
//		{
//        regValue = SPIBARREAD(spiSR);
//		}while((regValue & SPI_SR_BUSY) != 0x0); 
//}
//UINT8 spi_read(void)
//	{
//    UINT8 regValue = 0;
//    UINT8 	dataValue = 0;
//    UINT8  i = 0;
//	regValue = SPIBARREAD(spiRXFLR);
//	for(i = 0;i < regValue; i++)
//		{
//              dataValue = SPIBARREAD(spiDR);
//	/*	printf("dataValue == %x\n",dataValue);*/
//		}
//     /*  regValue = SPIBARREAD(spiDR);*/
//	return (dataValue);	
//	}
//void spidemo(UINT8 adrs)
//{
//    UINT32 rd_data;
//    /*reset*/
//    pciBar1RegW(0x88004,0x3);
//    pciBar1RegW(0x88004,0x0);
//    pciBar1RegW(0x88004,0x3);
//
//    /*init*/
//    //pciBar1RegW(0xc0000,0x7);
//    pciBar1RegW(0xc4014,100);
//    pciBar1RegW(0xc4008,1);
//    /*push data*/
//    pciBar1RegW(0xc4060,0x3);
//    pciBar1RegW(0xc4060,adrs);
//    pciBar1RegW(0xc4060,adrs);
//    pciBar1RegW(0xc4010,1);
//    rd_data = pciBar1RegR(0xc4028);
//    while ((rd_data & 0x5) != 0x4) 
//    {
//       rd_data = pciBar1RegR(0xc4028);
//    }
//    pciBar1RegW(0xc4010,0);
//    printf("spi_0_SR = %x\n", pciBar1RegR(0xc4028));
//    printf("spi_0_TXFLR = %x\n", pciBar1RegR(0xc4020));
//    printf("spi_0_RXFLR = %x\n", pciBar1RegR(0xc4024));
//}
void sioFifoEn(UINT32 channelNum)
{
UINT32 regValue = 0;
regValue = pciBar1RegR((sioBase[channelNum] + (FCR << 2)));
if ((regValue & (FCR_ENABLE_STS)) != (FCR_ENABLE_STS))
     pciBar1RegW((sioBase[channelNum] + (FCR << 2)), FCR_ENABLE);	
}	
UINT32 sioFifoWrite
	(
	UINT32 channelNum,
	UINT32 sendLen,
	UINT8 *pBuf
	)
      {
      UINT32 tflValue = 0;
      UINT32 i = 0;
      if (pBuf == NULL)
          return 0;
      tflValue = pciBar1RegR((sioBase[channelNum] + (TFL << 2)));
    /*  printf("tflValue == %d\n",tflValue); */
      if ((64 - tflValue) > sendLen)
	  	tflValue = sendLen;
      for(i = 0; i < (64 - tflValue); i++)
	  	pciBar1RegW((sioBase[channelNum] + (THR << 2)), *(pBuf + i));
      return i;	  
      }	  
UINT32 sioFifoRead
	(
	UINT32 channelNum,
	UINT32 revLen,
	UINT8 *pBuf
      )
      {
      UINT32 rflValue = 0;
      UINT32 i = 0;
      if (pBuf == NULL)
          return 0;
      rflValue = pciBar1RegR((sioBase[channelNum] + (RFL << 2)));
      if(rflValue == 0x0)
    	  return 0;
      if (revLen < rflValue)
	  	rflValue = revLen;
      for(i = 0; i < rflValue; i++)
	  	*(pBuf + i) = pciBar1RegR((sioBase[channelNum] + (RHR << 2)));
      return i;	  
      }
// ad0 channel a,b modify and test
// u12 == AD0 u13 == AD1
// 0-5V == U13.46 AD1 b channel 0-40v == U13.39 AD1 A channel
// 0-20mA == U12.46 AD0 b channel 0-20mA || 0-5v U12.39 AD0 a channel
// select 0x88004 2-5bit
void adInit(int ctrl)
{
UINT32 regBase;
UINT32 regValue = 0;
if (ctrl == 0x0)
	regBase = 0x70000 /*AD_0_BASE*/;
else if (ctrl == 0x1)
	regBase = 0x71000 /*AD_1_BASE*/;

pciBar1RegW((regBase + ad_cha_base_addr0), 0x8000*ctrl+0x0);
pciBar1RegW((regBase + ad_cha_base_addr0 + 0x4),0x8000*ctrl+0x2000);
pciBar1RegW((regBase + ad_cha_base_addr0 + 0x8),0x8000*ctrl+0x4000);
pciBar1RegW((regBase + ad_cha_base_addr0 + 0xc),0x8000*ctrl+0x6000);
pciBar1RegW(regBase + 0x30,0x3);
pciBar1RegW(regBase + 0x34,0x3);
pciBar1RegW((regBase + ad_ch_len),0x20);
pciBar1RegW((regBase + 0x04),0x1);
}

void adChannelSet(UINT8 channel)
{
pciBar1RegW(0x88004, (channel << 2));

}

void adStart(int ctrl)
{
UINT32 regBase;
UINT32 regValue = 0;
int i  = 0;



if (ctrl == 0x0)
	regBase = 0x70000/*AD_0_BASE*/;
else if (ctrl == 0x1)
	regBase = 0x71000/*AD_1_BASE*/;

pciBar1RegW((regBase + ad_start),0x01);

   //adStop(ctrl);

//adStop(ctrl);
}

void adStop(int ctrl)
{
	UINT32 regBase,srsValue;
	//void * temp;
	//temp = cacheDmaMalloc(512);
	if (ctrl == 0)
		regBase = AD_0_BASE;
	else if (ctrl == 1)
		regBase = AD_1_BASE;	
	pciBar1RegW((regBase + ad_done),0x01);	
	do
	    {
	    srsValue = pciBar1RegR(regBase + ad_done_st);	
	    }while((srsValue & ad_done_st_bit)!= 0x0);	
    //printf("address = %x\n", temp);
    //memset(temp,0x55,512);
	//pciDmaW(0x4000,temp,512);
}

void tempTest(int len)
{
#if 0
	void * temp;
	
	temp = memPartAlignedAlloc(memSysPartId, 0x10000, 0x1000);
	printf("DMA write address = %x\n",temp);
	pciDmaW(0,(UINT32)temp,len);
#endif
	UINT32 i;
	
	for(i = 0; i <= len; i++)
		pciBar1RegW(0x00005500,0x55);
	
}
