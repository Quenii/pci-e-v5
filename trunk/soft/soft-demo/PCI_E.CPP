#include "StdAfx.h"//这个头文件必须后期加上去
//#include <afx.h>//加这个头文件必须要将project下面的seting里的general从no using mfc 改为备选项任意之1.否则错误
#define KERNEL_64BIT
#include <windrvr.h>
#include "wdc_lib.h"
#include "wdc_defs.h"
#include "utils.h"
#include "status_strings.h"
//#include <stdio.h>//这个文件后期可以不要
#include "PCI_E.H"


#define PCIVENDORID 0x10ee  //特定PCIE的厂商号                          //厂商号
#define PCIDEVICEID	0x7		
#define STATBIT17   0x00020000
#define STATBIT16   0x00010000
#define SIMUOP      0x80000000   
#define REALOP		0xe0000000
pcie *ppcie;
HANDLE he=NULL;
pcie::pcie()
{
	ppcie = this;
	for (int i=0;i<16;i++)
	{
		pRbuffer[i]=pWbuffer[i]=pprDma[i]=ppwDma[i]=0;
	}
	pTrans=NULL;
	pDevCtx=NULL;
	hDev=NULL;
}
//获取最后一个错误产生的信息
void pcie::GetLastInfo(char * info)
{
	strcpy(info,infor);
}
BOOL pcie::ReadCfg(DWORD offset,UINT*outdata,UINT numbyte)//用于读取配置空间的数据信息
{
	if (!hDev)
	{
		strcpy(infor,"无效设备句柄值");
		return FALSE;
	}
	memset(outdata,0,4);
	DWORD dw;
	if(dw=WDC_PciReadCfg(hDev,offset, outdata, numbyte),dw==0)
		return TRUE;
//	strcpy(infor,Stat2Str(dw));
	return FALSE;
}
//打开指定设备，该函数仅仅是打开一个设备而已,若需要中断,DMA传输等功能,则需要调用
//另外的函数实现该函数调用后必须调用CloseDevice函数来关闭Windriver(无论该函数调用是否成功)
BOOL pcie::OpenDevice(DWORD vendorid=0x10ee,DWORD deviceid=7)
{
	DWORD dw;
	if(dw=WDC_SetDebugOptions(WDC_DBG_DEFAULT, NULL),dw!=WD_STATUS_SUCCESS)
	{
		strcpy(infor,"调试环境设置错误\n");
//		strcat(infor,Stat2Str(dw));
		return FALSE;
	}
	if(dw=WDC_DriverOpen(WDC_DRV_OPEN_DEFAULT,LICENSESTR),dw!=0)
	{
		strcpy(infor,"windriver 打开失败\n");
//		strcat(infor,Stat2Str(dw));
		return FALSE;
	}
	BZERO(scanResult);
	if(dw=WDC_PciScanDevices(vendorid, deviceid, &scanResult),dw!=WD_STATUS_SUCCESS)
	{
		strcpy(infor,"获取指定厂商号和设备号的详细信息失败！\n");
//		strcat(infor,Stat2Str(dw));
//		WDC_PciDeviceClose(hDev);
		WDC_DriverClose();
		return FALSE;
	}
	BZERO(deviceInfo);
	deviceInfo.pciSlot=scanResult.deviceSlot[0];
	if (dw=WDC_PciGetDeviceInfo(&deviceInfo),dw!=WD_STATUS_SUCCESS)
	{
		strcpy(infor,"设备详细信息获取失败\n");
//		strcat(infor,Stat2Str(dw));
		WDC_PciDeviceClose(hDev);
		WDC_DriverClose();
		return FALSE;
	}
	pDevCtx=NULL;
	pDevCtx=(PPCIDEV_CTX)malloc(sizeof(PCIDEV_CTX));
	if(!pDevCtx)
	{
		strcpy(infor,"设备上下文内存分配失败\n");
		WDC_PciDeviceClose(hDev);
		WDC_DriverClose();
		return FALSE;
	}
	hDev=NULL;
	if(dw=WDC_PciDeviceOpen(&hDev, &deviceInfo, pDevCtx, NULL, NULL, NULL),dw!=WD_STATUS_SUCCESS)
	{
		strcpy(infor,"指定设备打开失败\n");
//		strcat(infor,Stat2Str(dw));
		//WDC_DriverClose();
		free(pDevCtx);
		WDC_PciDeviceClose(hDev);
		WDC_DriverClose();
		return FALSE;
	}

	return TRUE;
}
///////////////////////////////////////////////////////////////////////////////////////////////
BOOL pcie::ReadBAR0(DWORD offset,UINT* outdata,UINT numbyte=0)
{
	DWORD dw;
	KPTR offset_64bit = offset;
	if(dw=WDC_ReadAddr32(hDev, 0, offset_64bit, outdata),dw!=0)
	{
		strcpy(infor,"读取BAR0空间错误\n");
//		strcat(infor,Stat2Str(dw));
		return FALSE;
	}
	return TRUE;

	//WD_TRANSFER trns;
	//BZERO(trns);
	//trns.cmdTrans = RP_DWORD; // R-Read P-Port WORD
	//trns.dwPort = offset;
	//WD_Transfer( hDev, &trns); // Perform read
	//*outdata = trns.Data.Word;
	//return TRUE;

}
BOOL pcie::WriteBAR0(DWORD offset,UINT indata,UINT numbyte=0)
{
	DWORD dw;
	KPTR offset_64bit = offset;
	if(dw=WDC_WriteAddr32(hDev,0,offset_64bit,indata),dw!=0)
	{
		strcpy(infor,"写BAR0空间错误\n");
//		strcat(infor,Stat2Str(dw));
		return FALSE;
	}
	return TRUE;

	//WD_TRANSFER trns;
	//BZERO(trns);
	//trns.cmdTrans = WP_DWORD; // W-Write P-Port DWORD
	//trns.dwPort = offset;
	//trns.Data.Dword = indata;
	//WD_Transfer( hDev, &trns); // Perform write
	//return TRUE;

}

////////////////////////////////////////////////////////////////////////////////////////////////
BOOL pcie::DMAReadMenAlloc(UINT menBlocknum=4,UINT blocksize=32*1024)
{
	DWORD status;
	rBlockSize=blocksize;//缓冲大小
	rBNum=menBlocknum;//缓冲个数
	if(menBlocknum>16||menBlocknum<2)
	{
		strcpy(infor,"你输入的内存块数大于16或者小于2，系统拒绝执行内存分配\n");
		CloseDevice();
		return FALSE;
	}
	if (blocksize>64*1024*1024||blocksize<1024)//这里被改变成1K的单位，最后必须要改过来
	{
		strcpy(infor,"你输入的每块内存大小超过64M或者小于1K，系统拒绝执行内存分配\n");
		CloseDevice();
		return FALSE;
	}

	//下面开始将缓冲区绑定到BAR0上去。
	for(UINT i=0;i<menBlocknum;i++)
	if(status=WDC_DMAContigBufLock(hDev,&pRbuffer[i],DMA_WRITE_TO_DEVICE,blocksize,&pprDma[i]),status!=0)
	{	
		strcpy(infor,"物理内存映射失败\n");
//		strcat(infor,Stat2Str(status));
		pprDma[i]=NULL;
		pRbuffer[i]=NULL;
		CloseDevice();
		return FALSE;
	}	
	return TRUE;
}
BOOL pcie::DMAWriteMenAlloc(UINT menBlocknum=6,UINT blocksize=32*1024)
{
	//内存申请成功或者失败，内存块大小都是首先赋值到wBlockSize，另外如果部分成功，部分失败
	//时，ppwDma[i]不为0表示成功的，有助于内存清理
	DWORD status;
	wBlockSize=blocksize;
	wBnum=menBlocknum;
	if(menBlocknum>16||menBlocknum<2)
	{
		strcpy(infor,"你输入的内存块数大于16或者小于2，系统拒绝执行内存分配\n");
		CloseDevice();
		return FALSE;
	}
	if (blocksize>64*1024*1024||blocksize<1024)//这里被改变成1K的单位，最后必须要改过来
	{
		strcpy(infor,"你输入的每块内存大小超过64M或者小于1K，系统拒绝执行内存分配\n");
		CloseDevice();
		return FALSE;
	}
	
	//分配连续多个内存块空间
	for(UINT i=0;i<menBlocknum;i++)
	if(status=WDC_DMAContigBufLock(hDev,&pWbuffer[i],DMA_READ_FROM_DEVICE,blocksize,&ppwDma[i]),status!=0)
	{	
		strcpy(infor,"物理内存映射失败\n");
//		strcat(infor,Stat2Str(status));
		pWbuffer[i]=ppwDma[i]=NULL;
		CloseDevice();
		return FALSE;
	}
	return TRUE;
}

UINT pcie::GetPhsicalWBufferAdd(UINT index)
{
	return ppwDma[index]->Page[0].pPhysicalAddr;
}
UINT pcie::GetPhsicalRBufferAdd(UINT index)
{
	return pprDma[index]->Page[0].pPhysicalAddr;
}
////////////////////////////////////////
void pcie::SetTransBlkNum(UINT num)
{
	tranBlock=num;
	areadyTran=0;

}
////////////////////////////////////////
 void IntDealFunction(WDC_DEVICE_HANDLE hDev,PCIINT_RESULT *pIntResult)
{
	UINT dw;
	ppcie->ReadBAR0(0x28,&dw);//读控制状态寄存器
	if ((dw&2)==2)//dma写完成
	{
		ppcie->areadyTran++;
		ppcie->WriteBAR0(0x28,dw);//清除DMA写完成标志位
			SetEvent(he);
	}
	else if((dw&8)==8)
	{
		ppcie->areadyTran++;
		ppcie->WriteBAR0(0x28,dw);//清除DMA读完成标志位
		SetEvent(he);
	}
}

DWORD WaitForComplete(LPVOID lpara)
{
	DWORD status;
	BOOL readaction=FALSE;
	pcie *p;
	CTime start;
	UINT valuee;
	start=CTime::GetCurrentTime();
	p=(pcie*)lpara;
	readaction=p->wmemory;
	while (1)
	{
		if(!p->stop&&readaction)
		{
			status=WaitForSingleObject(he,INFINITE);
			if (status!=WAIT_OBJECT_0)
			{
				continue;
			}

		}
		readaction=TRUE;
////可以在这里写文件---若文件句柄为非空
		
		if(p->wmemory)
		{
			if(p->hfile)
				///////////////////////////////////数据转移到磁盘
				while(1)
				{
					valuee=p->MemToFile();//将数据写入磁盘
					if(valuee==FALSE)
						break;
					if(valuee==5)//写文件出错
					{
						p->stop=TRUE;//自我终结
						break;
					}
					
				}		
				///////////////////////////////////数据转移到磁盘完毕
		}


/////////////////////////////////////////////////从磁盘将数据转到内存
		if(!p->wmemory)
		{
			///////////////////////////////////数据从磁盘转移到内存
			while(1)
			{
				valuee=p->DiscToMem();//将数据写入内存
				if(valuee==FALSE)
					break;
				if(valuee==5)//写文件出错
				{
					p->stop=TRUE;//自我终结
					break;
				}
				
			}
			///////////////////////////////////数据转移到内存完毕
		}

/////////////////////////////////////////////////磁盘数据转到内存结束
		CTimeSpan end=CTime::GetCurrentTime()-start;
		p->times=end.GetTotalSeconds();
		
		if(p->stop)//还得通知程序已经完成
		{		
			CTimeSpan end=CTime::GetCurrentTime()-start;
			p->times=end.GetTotalSeconds();
			if(p->hev)//若外部使用了事件等待，则通知外部
				SetEvent(p->hev);
			p->isWork=FALSE;			
			p->CloseDevice();
			break;
		}
////////////////////////////////将数据从PCIE转移到内存
		if (p->wmemory)
		{
			if(((p->addrwpointer+1)%p->wBnum)==p->read)//若写指针追到读指针---不执行任何操作
			{
				readaction=FALSE;
 				continue;
			}
			else
			{
				if(p->tranBlock>p->areadyTran)//已传输的块数小于需传块数时，继续-----当等于的时候就不再继续，而是将写指针前移动一位
				{
					p->addrwpointer=(p->addrwpointer+1)%p->wBnum;//设置缓冲区的时候设置的------------------------->这个地方要加实际应用的处理函数
					p->WriteBAR0(4,p->GetPhsicalWBufferAdd(p->addrwpointer));//启动的时候为0
					p->WriteBAR0(8,0);
					p->WriteBAR0(0x28,1);//再次启动--可以放在线程里面去
				}
				else//已传输的块数大于等于要传块数时，移动一个指针，让函数在上面终止
				{
					p->addrwpointer=(p->addrwpointer+1)%p->wBnum;
					p->stop=TRUE;//自我终结

				}
			}
		}
////////////////////////////////////////////////////////////将数据从内存移动到PCIE
		else//当DMA读指针addrrpointer追到磁盘写指针write时，表明没有数据，write不能追上addrrpointer
		{
 			if(p->addrrpointer==p->write)
			{
				readaction=FALSE;
 				continue;
			}
 			else
 			{
				//if (p->ReadBAR0(0x44,&valuee),(valuee&STATBIT17)!=STATBIT17)
				//if (p->ReadBAR0(0x38,&valuee),(valuee&0x40000000)!=0x40000000)
				if (p->ReadBAR0(0x38,&valuee),(valuee&0x00800000)!=0x00800000)
				{
					readaction=FALSE;
 					continue;
				}
 				if(p->tranBlock>p->areadyTran)//已传输的块数小于需传块数时，继续
 				{
					p->WriteBAR0(0x0c,p->GetPhsicalRBufferAdd(p->addrrpointer));
					p->WriteBAR0(0x10,0);
 					p->addrrpointer=(p->addrrpointer+1)%p->rBNum;//设置缓冲区的时候设置的------------------------->这个地方要加实际应用的处理函数
 					p->WriteBAR0(0x28,4);//再次启动
 				}
 				else//已传输的块数大于等于要传块数时，移动一个指针，让函数在上面终止
 				{
 					p->addrrpointer=(p->addrrpointer+1)%p->rBNum;
 					p->stop=TRUE;//自我终结
					
 				}
 			}

		}
/////////////////////////////////
	}
	
	return 0;
}
//解析参数并调用中断处理函数
void DLLCALLCONV FuncIntHandler(PVOID pData)
{
	PWDC_DEVICE pDev = (PWDC_DEVICE)pData;
    PPCIDEV_CTX pDevCtx = (PPCIDEV_CTX)WDC_GetDevContext(pDev);
    PCIINT_RESULT intResult;
    BZERO(intResult);
    intResult.dwCounter = pDev->Int.dwCounter;
    intResult.dwLost = pDev->Int.dwLost;
    intResult.waitResult = (WD_INTERRUPT_WAIT_RESULT)pDev->Int.fStopped;
    /* Execute the diagnostics application's interrupt handler routine */
    pDevCtx->funcDiagIntHandler((WDC_DEVICE_HANDLE)pDev, &intResult);
}
BOOL pcie::IntEnable(WDC_DEVICE_HANDLE hDev, PCIINT_HANDLER funcIntHandler)
{
	DWORD dwStatus;
    PWDC_DEVICE pDev = (PWDC_DEVICE)hDev;
    PPCIDEV_CTX pDevCtx;	
    WDC_ADDR_DESC *pAddrDesc=NULL;
    pDevCtx = (PPCIDEV_CTX)WDC_GetDevContext(pDev);
    /* Check if interrupts are already enabled */
    if (WDC_IntIsEnabled(hDev))
        return TRUE;
    #define NUM_TRANS_CMDS 1
    pTrans = (WD_TRANSFER*)calloc(NUM_TRANS_CMDS, sizeof(WD_TRANSFER));
    if (!pTrans)
	{
		strcpy(infor,"IntEnable函数中pTrans内存分配失败\n");
        return FALSE; 
	}
    pAddrDesc = &pDev->pAddrDesc[0]; //BAR0 
    /* Define the number of interrupt transfer commands to use */
	pTrans[0].dwPort         = pAddrDesc->kptAddr + 0x24;
	pTrans[0].cmdTrans       = WM_DWORD;
	pTrans[0].Data.Dword     = 3;
    pDevCtx->funcDiagIntHandler = funcIntHandler; 
    /* Enable the interrupts */
    dwStatus = WDC_IntEnable(hDev, pTrans, NUM_TRANS_CMDS, INTERRUPT_CMD_COPY,
		FuncIntHandler, (PVOID)pDev, WDC_IS_KP(hDev));
    if (WD_STATUS_SUCCESS != dwStatus)
	{
		strcpy(infor,"中断处理函数注册失败\n");
//		strcat(infor,Stat2Str(dwStatus));
		return FALSE;
	}        
	return TRUE;
}



//获取传输用时
UINT pcie::GetTimes()
{
	return times;
}
UINT pcie::GetTransBlock()
{
	return areadyTran;
}
void pcie::StopDMA()
{
	stop=TRUE;
	SetEvent(he);
}



//从新初始化参数的时候调用---常见的是模块调用startDma多次的时候
void pcie::CloseDevice()
{
	for (int i=0;i<16;i++)
	{
		if(pprDma[i])//内存映射失败后必须做到事（防止部分分配成功，部分分配失败）
		{
			WDC_DMABufUnlock(pprDma[i]);
			pprDma[i]=NULL;
			pRbuffer[i]=NULL;//必须还原，以便下一次是空的
		}
		if(ppwDma[i])
		{
			WDC_DMABufUnlock(ppwDma[i]);
			ppwDma[i]=NULL;
			pWbuffer[i]=NULL;//必须还原，以便下一次是空的
		}		
	}
	if(pDevCtx)//内存分配失败后必调用
	{
		free(pDevCtx);
		pDevCtx=NULL;
	}
	
	if(pTrans)//中断处理函数之前的一个函数开辟
	{
		free(pTrans);
		pTrans=NULL;
	}
	if(hDev)
	{	
		if (WDC_IntIsEnabled(hDev))//开始工作时，模块设置了中断方式，所以必须清除
		{
			WDC_IntDisable(hDev);
		}
	}
	if(hDev)
	{
		WriteBAR0(0x20,0xffffffff);//启动中断掩码功能
		//WriteBAR0(0x40,0);//----------------------------------
		WriteBAR0(0x38,0);
	}
	if(hDev)
	{
		WDC_PciDeviceClose(hDev);
		hDev=NULL;
	}
	WDC_DriverClose();//内存分配失败后必须调用
    //初始化为原值
	if(he)
	{
		CloseHandle(he);
		he=NULL;
	}
}
BOOL pcie::StartDMA(BOOL wmen,HANDLE hf=NULL,BOOL isrealop=TRUE,HANDLE finishEven=NULL)
{
	UINT reg28=0;
	isreal=isrealop;//该变量不用初始化
	wmemory=wmen;
	intUse=TRUE;
	hev=finishEven;//挂上通知完成传输的事件句柄
	hfile=hf;
	if(wmen==FALSE)
	{
		if(hf==NULL)
		{
			strcpy(infor,"读内存数据并将数据传输到PCI时文件句柄必须存在！\n");
			CloseDevice();
			return FALSE;
		}
	}
	he=CreateEvent(NULL,FALSE,FALSE,NULL);
 	if(!FPGAReset())
 	{
 		return FALSE;
 	}
	if (wmemory)//写内存
	{
		
		if(!IntEnable(hDev, IntDealFunction))
		{   
				//关闭Windriver处理
			CloseDevice();
			return FALSE;
		}
		WriteBAR0(0x20,0x7ffffffe);//关闭中断屏蔽
		//设置初始DMA写地址,长度等
		if(!WriteBAR0(4,ppwDma[0]->Page[0].pPhysicalAddr)||!WriteBAR0(8,0)||!WriteBAR0(0x18,wBlockSize,0))
		{   
			//关闭Windriver处理
			CloseDevice();
			return FALSE;
		}
		addrwpointer=0;
		//启动DMA
		if(!ReadBAR0(0x28, &reg28,0))
		{   

			//关闭Windriver处理
			CloseDevice();
			return FALSE;
		}
		reg28=reg28|1;
		if(!WriteBAR0(0x28,reg28,0))
		{   
			//关闭Windriver处理
			CloseDevice();
			return FALSE;
		}
		if (isrealop)
		{		
			//WriteBAR0(0x40,0x40000000);//----------------------------------shijixie
			WriteBAR0(0x38,0x01);//----------------------------------shijixie

		}
		else
		{
			//WriteBAR0(0x40,0x50000000);//----------------------------------monixie
			WriteBAR0(0x38,0x05);//----------------------------------monixie

		}
	}
	else//读内存
	{
	
		if(!IntEnable(hDev, IntDealFunction))
		{   
				//关闭Windriver处理
			CloseDevice();
			return FALSE;
		}
		WriteBAR0(0x20,0x7ffffffd);
		if (isrealop)
		{		
			//WriteBAR0(0x40,0x20000000);//----------------------------------shiji duqu
			WriteBAR0(0x38,0x02);//----------------------------------shiji duqu
			
		}
		else
		{
			//WriteBAR0(0x40,0x30000000);//----------------------------------moliduqu
			WriteBAR0(0x38,0x06);//----------------------------------moliduqu 
			
		}
		//设置初始DMA写地址,长度等
		if(!WriteBAR0(0x0c,pprDma[0]->Page[0].pPhysicalAddr)||!WriteBAR0(0x10,0,0)||!WriteBAR0(0x1c,rBlockSize,0))
		{   
			//关闭Windriver处理
			CloseDevice();
			return FALSE;
		}
		//启动DMA
		addrrpointer=0;	
	}
	//创建一个线程来处理等待事件
	times=0;
	stop=FALSE;
	isWork=TRUE;
	if(hfile==NULL)
	read=write=10000;//文件使用
	else
	read=write=0;//文件使用
	CreateThread(NULL,0,(LPTHREAD_START_ROUTINE)WaitForComplete,this,0,NULL);
  return TRUE; 
}
BOOL pcie::MemToFile()//被线程调用
{
	isWriteFile=ISWRITEFILE;
	if (read==10000)
	{
		return FALSE;
	}
	if(read==addrwpointer)//addrwpointer初始值会被设置为0
		return FALSE;
	else
	{
		ULONG wsize;
		if(isWriteFile==70)
		{
			WriteFile(hfile,pWbuffer[read],wBlockSize,&wsize,0);
			if(wsize!=wBlockSize)
			{
				strcpy(infor,"写文件时产生错误\n");
				return 5;//
			}
		}
		
		read=(++read)%wBnum;

	}
	return TRUE;
}

BOOL pcie::DiscToMem()//将磁盘文件数据写入内存DMA的读缓冲区----------写优先，写不能追到读，读（DMA），可追到写
{
	if(((write+1)%rBNum)==addrrpointer)//addrrpointer初始值会被设置为0
		return FALSE;
	else
	{
		ULONG wsize;
		isReadFile = ISREADFILE;
		if (isReadFile == 80)
		{
			ReadFile(hfile,pRbuffer[write],rBlockSize,&wsize,0);
			if(wsize!=rBlockSize)
			{
				strcpy(infor,"读文件时产生错误\n");
				return 5;//
			}		
		}

		write=(++write)%rBNum;
		
	}
	return TRUE;

}
BOOL pcie::TransIsDown()//供程序查询使用
{
	return isWork;
}

BOOL pcie::FPGAReset()
{
	UINT reg44=0,countt=0;
	//WriteBAR0(0x40,0x80000000);
	WriteBAR0(0x2C,0x01);
	Sleep(1);
	//WriteBAR0(0x40,0x00000000);
	WriteBAR0(0x2C,0x00000000);
	Sleep(1);
	while (1)
	{			
		countt++;
		//ReadBAR0(0x44, &reg44);
		//WDC_ReadAddr32(hDev,0,0x44,&reg44);//stat reg
		//WDC_ReadAddr32(hDev,0,0x38,&reg44);//stat reg
		ReadBAR0(0x38, &reg44);
		if (isreal)
		{
			//if((reg44&REALOP)==REALOP)//DDR@2,链路和光纤检查
			if((reg44&0x00070000)==0x00070000)//DDR@2,链路和光纤检查
			{
				return TRUE;
			}
		}
		else
		{
			//if((reg44&SIMUOP)==SIMUOP)//链路检查
			if((reg44&0x00010000)==0x00010000)//链路检查
			{
				return TRUE;
			}

		}
		
		if (countt>10)
		{	
			strcpy(infor,"");
			//if ((reg44&0x80000000)!=0x80000000)
			if ((reg44&0x00010000)!=0x00010000)
			{
				strcpy(infor,"PCIE链路异常");
			}
			//if ((reg44&0x40000000)!=0x40000000)
			if ((reg44&0x00020000)!=0x00020000)
			{
				strcat(infor,"DDR2链路异常");
			}
			//if ((reg44&0x20000000)!=0x20000000)
			if ((reg44&0x00040000)!=0x00040000)
			{
				strcat(infor,"光纤链路异常");
			}
			CloseDevice();
			return FALSE;
		}
		Sleep(100);
	}
	return FALSE;
}

BOOL pcie::IsDeviceOpen()
{
	if (hDev)
	{
		return TRUE;
	}
	return FALSE;

}

BOOL pcie::ChainIniCheck()
{
	if(!OpenDevice())
		return FALSE;
	UINT rg44;

	return TRUE;

	//WriteBAR0(0x40,0x8000000);
	Sleep(2);
	//WriteBAR0(0x40,0);
	Sleep(2000);
	//ReadBAR0(0x44,&rg44,4);
	//if ((rg44&0x20000000)==0x20000000)
	//{
		//CloseDevice();
		//return TRUE;
	//}
	//CloseDevice();
	//return FALSE;

}
