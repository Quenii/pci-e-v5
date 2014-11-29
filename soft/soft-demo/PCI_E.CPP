#include "StdAfx.h"//���ͷ�ļ�������ڼ���ȥ
//#include <afx.h>//�����ͷ�ļ�����Ҫ��project�����seting���general��no using mfc ��Ϊ��ѡ������֮1.�������
#include <windrvr.h>
#include "wdc_lib.h"
#include "wdc_defs.h"
#include "utils.h"
#include "status_strings.h"
//#include <stdio.h>//����ļ����ڿ��Բ�Ҫ
#include "PCI_E.H"
#define PCIVENDORID 0x10ee  //�ض�PCIE�ĳ��̺�                          //���̺�
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
//��ȡ���һ�������������Ϣ
void pcie::GetLastInfo(char * info)
{
	strcpy(info,infor);
}
BOOL pcie::ReadCfg(DWORD offset,UINT*outdata,UINT numbyte)//���ڶ�ȡ���ÿռ��������Ϣ
{
	if (!hDev)
	{
		strcpy(infor,"��Ч�豸���ֵ");
		return FALSE;
	}
	memset(outdata,0,4);
	DWORD dw;
	if(dw=WDC_PciReadCfg(hDev,offset, outdata, numbyte),dw==0)
		return TRUE;
//	strcpy(infor,Stat2Str(dw));
	return FALSE;
}
//��ָ���豸���ú��������Ǵ�һ���豸����,����Ҫ�ж�,DMA����ȹ���,����Ҫ����
//����ĺ���ʵ�ָú������ú�������CloseDevice�������ر�Windriver(���۸ú��������Ƿ�ɹ�)
BOOL pcie::OpenDevice(DWORD vendorid=0x10ee,DWORD deviceid=7)
{
	DWORD dw;
	if(dw=WDC_SetDebugOptions(WDC_DBG_DEFAULT, NULL),dw!=WD_STATUS_SUCCESS)
	{
		strcpy(infor,"���Ի������ô���\n");
//		strcat(infor,Stat2Str(dw));
		return FALSE;
	}
	if(dw=WDC_DriverOpen(WDC_DRV_OPEN_DEFAULT,LICENSESTR),dw!=0)
	{
		strcpy(infor,"windriver ��ʧ��\n");
//		strcat(infor,Stat2Str(dw));
		return FALSE;
	}
	BZERO(scanResult);
	if(dw=WDC_PciScanDevices(vendorid, deviceid, &scanResult),dw!=WD_STATUS_SUCCESS)
	{
		strcpy(infor,"��ȡָ�����̺ź��豸�ŵ���ϸ��Ϣʧ�ܣ�\n");
//		strcat(infor,Stat2Str(dw));
//		WDC_PciDeviceClose(hDev);
		WDC_DriverClose();
		return FALSE;
	}
	BZERO(deviceInfo);
	deviceInfo.pciSlot=scanResult.deviceSlot[0];
	if (dw=WDC_PciGetDeviceInfo(&deviceInfo),dw!=WD_STATUS_SUCCESS)
	{
		strcpy(infor,"�豸��ϸ��Ϣ��ȡʧ��\n");
//		strcat(infor,Stat2Str(dw));
		WDC_PciDeviceClose(hDev);
		WDC_DriverClose();
		return FALSE;
	}
	pDevCtx=NULL;
	pDevCtx=(PPCIDEV_CTX)malloc(sizeof(PCIDEV_CTX));
	if(!pDevCtx)
	{
		strcpy(infor,"�豸�������ڴ����ʧ��\n");
		WDC_PciDeviceClose(hDev);
		WDC_DriverClose();
		return FALSE;
	}
	hDev=NULL;
	if(dw=WDC_PciDeviceOpen(&hDev, &deviceInfo, pDevCtx, NULL, NULL, NULL),dw!=WD_STATUS_SUCCESS)
	{
		strcpy(infor,"ָ���豸��ʧ��\n");
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
	if(dw=WDC_ReadAddr32(hDev, 0, offset, outdata),dw!=0)
	{
		strcpy(infor,"��ȡBAR0�ռ����\n");
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
	if(dw=WDC_WriteAddr32(hDev,0,offset,indata),dw!=0)
	{
		strcpy(infor,"дBAR0�ռ����\n");
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
	rBlockSize=blocksize;//�����С
	rBNum=menBlocknum;//�������
	if(menBlocknum>16||menBlocknum<2)
	{
		strcpy(infor,"��������ڴ��������16����С��2��ϵͳ�ܾ�ִ���ڴ����\n");
		CloseDevice();
		return FALSE;
	}
	if (blocksize>64*1024*1024||blocksize<1024)//���ﱻ�ı��1K�ĵ�λ��������Ҫ�Ĺ���
	{
		strcpy(infor,"�������ÿ���ڴ��С����64M����С��1K��ϵͳ�ܾ�ִ���ڴ����\n");
		CloseDevice();
		return FALSE;
	}

	//���濪ʼ���������󶨵�BAR0��ȥ��
	for(UINT i=0;i<menBlocknum;i++)
	if(status=WDC_DMAContigBufLock(hDev,&pRbuffer[i],DMA_WRITE_TO_DEVICE,blocksize,&pprDma[i]),status!=0)
	{	
		strcpy(infor,"�����ڴ�ӳ��ʧ��\n");
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
	//�ڴ�����ɹ�����ʧ�ܣ��ڴ���С�������ȸ�ֵ��wBlockSize������������ֳɹ�������ʧ��
	//ʱ��ppwDma[i]��Ϊ0��ʾ�ɹ��ģ��������ڴ�����
	DWORD status;
	wBlockSize=blocksize;
	wBnum=menBlocknum;
	if(menBlocknum>16||menBlocknum<2)
	{
		strcpy(infor,"��������ڴ��������16����С��2��ϵͳ�ܾ�ִ���ڴ����\n");
		CloseDevice();
		return FALSE;
	}
	if (blocksize>64*1024*1024||blocksize<1024)//���ﱻ�ı��1K�ĵ�λ��������Ҫ�Ĺ���
	{
		strcpy(infor,"�������ÿ���ڴ��С����64M����С��1K��ϵͳ�ܾ�ִ���ڴ����\n");
		CloseDevice();
		return FALSE;
	}
	
	//������������ڴ��ռ�
	for(UINT i=0;i<menBlocknum;i++)
	if(status=WDC_DMAContigBufLock(hDev,&pWbuffer[i],DMA_READ_FROM_DEVICE,blocksize,&ppwDma[i]),status!=0)
	{	
		strcpy(infor,"�����ڴ�ӳ��ʧ��\n");
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
	ppcie->ReadBAR0(0x28,&dw);//������״̬�Ĵ���
	if ((dw&2)==2)//dmaд���
	{
		ppcie->areadyTran++;
		ppcie->WriteBAR0(0x28,dw);//���DMAд��ɱ�־λ
			SetEvent(he);
	}
	else if((dw&8)==8)
	{
		ppcie->areadyTran++;
		ppcie->WriteBAR0(0x28,dw);//���DMA����ɱ�־λ
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
////����������д�ļ�---���ļ����Ϊ�ǿ�
		
		if(p->wmemory)
		{
			if(p->hfile)
				///////////////////////////////////����ת�Ƶ�����
				while(1)
				{
					valuee=p->MemToFile();//������д�����
					if(valuee==FALSE)
						break;
					if(valuee==5)//д�ļ�����
					{
						p->stop=TRUE;//�����ս�
						break;
					}
					
				}		
				///////////////////////////////////����ת�Ƶ��������
		}


/////////////////////////////////////////////////�Ӵ��̽�����ת���ڴ�
		if(!p->wmemory)
		{
			///////////////////////////////////���ݴӴ���ת�Ƶ��ڴ�
			while(1)
			{
				valuee=p->DiscToMem();//������д���ڴ�
				if(valuee==FALSE)
					break;
				if(valuee==5)//д�ļ�����
				{
					p->stop=TRUE;//�����ս�
					break;
				}
				
			}
			///////////////////////////////////����ת�Ƶ��ڴ����
		}

/////////////////////////////////////////////////��������ת���ڴ����
		CTimeSpan end=CTime::GetCurrentTime()-start;
		p->times=end.GetTotalSeconds();
		
		if(p->stop)//����֪ͨ�����Ѿ����
		{		
			CTimeSpan end=CTime::GetCurrentTime()-start;
			p->times=end.GetTotalSeconds();
			if(p->hev)//���ⲿʹ�����¼��ȴ�����֪ͨ�ⲿ
				SetEvent(p->hev);
			p->isWork=FALSE;			
			p->CloseDevice();
			break;
		}
////////////////////////////////�����ݴ�PCIEת�Ƶ��ڴ�
		if (p->wmemory)
		{
			if(((p->addrwpointer+1)%p->wBnum)==p->read)//��дָ��׷����ָ��---��ִ���κβ���
			{
				readaction=FALSE;
 				continue;
			}
			else
			{
				if(p->tranBlock>p->areadyTran)//�Ѵ���Ŀ���С���贫����ʱ������-----�����ڵ�ʱ��Ͳ��ټ��������ǽ�дָ��ǰ�ƶ�һλ
				{
					p->addrwpointer=(p->addrwpointer+1)%p->wBnum;//���û�������ʱ�����õ�------------------------->����ط�Ҫ��ʵ��Ӧ�õĴ�������
					p->WriteBAR0(4,p->GetPhsicalWBufferAdd(p->addrwpointer));//������ʱ��Ϊ0
					p->WriteBAR0(8,0);
					p->WriteBAR0(0x28,1);//�ٴ�����--���Է����߳�����ȥ
				}
				else//�Ѵ���Ŀ������ڵ���Ҫ������ʱ���ƶ�һ��ָ�룬�ú�����������ֹ
				{
					p->addrwpointer=(p->addrwpointer+1)%p->wBnum;
					p->stop=TRUE;//�����ս�

				}
			}
		}
////////////////////////////////////////////////////////////�����ݴ��ڴ��ƶ���PCIE
		else//��DMA��ָ��addrrpointer׷������дָ��writeʱ������û�����ݣ�write����׷��addrrpointer
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
 				if(p->tranBlock>p->areadyTran)//�Ѵ���Ŀ���С���贫����ʱ������
 				{
					p->WriteBAR0(0x0c,p->GetPhsicalRBufferAdd(p->addrrpointer));
					p->WriteBAR0(0x10,0);
 					p->addrrpointer=(p->addrrpointer+1)%p->rBNum;//���û�������ʱ�����õ�------------------------->����ط�Ҫ��ʵ��Ӧ�õĴ�������
 					p->WriteBAR0(0x28,4);//�ٴ�����
 				}
 				else//�Ѵ���Ŀ������ڵ���Ҫ������ʱ���ƶ�һ��ָ�룬�ú�����������ֹ
 				{
 					p->addrrpointer=(p->addrrpointer+1)%p->rBNum;
 					p->stop=TRUE;//�����ս�
					
 				}
 			}

		}
/////////////////////////////////
	}
	
	return 0;
}
//���������������жϴ�������
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
		strcpy(infor,"IntEnable������pTrans�ڴ����ʧ��\n");
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
		strcpy(infor,"�жϴ�������ע��ʧ��\n");
//		strcat(infor,Stat2Str(dwStatus));
		return FALSE;
	}        
	return TRUE;
}



//��ȡ������ʱ
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



//���³�ʼ��������ʱ�����---��������ģ�����startDma��ε�ʱ��
void pcie::CloseDevice()
{
	for (int i=0;i<16;i++)
	{
		if(pprDma[i])//�ڴ�ӳ��ʧ�ܺ���������£���ֹ���ַ���ɹ������ַ���ʧ�ܣ�
		{
			WDC_DMABufUnlock(pprDma[i]);
			pprDma[i]=NULL;
			pRbuffer[i]=NULL;//���뻹ԭ���Ա���һ���ǿյ�
		}
		if(ppwDma[i])
		{
			WDC_DMABufUnlock(ppwDma[i]);
			ppwDma[i]=NULL;
			pWbuffer[i]=NULL;//���뻹ԭ���Ա���һ���ǿյ�
		}		
	}
	if(pDevCtx)//�ڴ����ʧ�ܺ�ص���
	{
		free(pDevCtx);
		pDevCtx=NULL;
	}
	
	if(pTrans)//�жϴ�������֮ǰ��һ����������
	{
		free(pTrans);
		pTrans=NULL;
	}
	if(hDev)
	{	
		if (WDC_IntIsEnabled(hDev))//��ʼ����ʱ��ģ���������жϷ�ʽ�����Ա������
		{
			WDC_IntDisable(hDev);
		}
	}
	if(hDev)
	{
		WriteBAR0(0x20,0xffffffff);//�����ж����빦��
		//WriteBAR0(0x40,0);//----------------------------------
		WriteBAR0(0x38,0);
	}
	if(hDev)
	{
		WDC_PciDeviceClose(hDev);
		hDev=NULL;
	}
	WDC_DriverClose();//�ڴ����ʧ�ܺ�������
    //��ʼ��Ϊԭֵ
	if(he)
	{
		CloseHandle(he);
		he=NULL;
	}
}
BOOL pcie::StartDMA(BOOL wmen,HANDLE hf=NULL,BOOL isrealop=TRUE,HANDLE finishEven=NULL)
{
	UINT reg28=0;
	isreal=isrealop;//�ñ������ó�ʼ��
	wmemory=wmen;
	intUse=TRUE;
	hev=finishEven;//����֪ͨ��ɴ�����¼����
	hfile=hf;
	if(wmen==FALSE)
	{
		if(hf==NULL)
		{
			strcpy(infor,"���ڴ����ݲ������ݴ��䵽PCIʱ�ļ����������ڣ�\n");
			CloseDevice();
			return FALSE;
		}
	}
	he=CreateEvent(NULL,FALSE,FALSE,NULL);
 	if(!FPGAReset())
 	{
 		return FALSE;
 	}
	if (wmemory)//д�ڴ�
	{
		
		if(!IntEnable(hDev, IntDealFunction))
		{   
				//�ر�Windriver����
			CloseDevice();
			return FALSE;
		}
		WriteBAR0(0x20,0x7ffffffe);//�ر��ж�����
		//���ó�ʼDMAд��ַ,���ȵ�
		if(!WriteBAR0(4,ppwDma[0]->Page[0].pPhysicalAddr)||!WriteBAR0(8,0)||!WriteBAR0(0x18,wBlockSize,0))
		{   
			//�ر�Windriver����
			CloseDevice();
			return FALSE;
		}
		addrwpointer=0;
		//����DMA
		if(!ReadBAR0(0x28, &reg28,0))
		{   

			//�ر�Windriver����
			CloseDevice();
			return FALSE;
		}
		reg28=reg28|1;
		if(!WriteBAR0(0x28,reg28,0))
		{   
			//�ر�Windriver����
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
	else//���ڴ�
	{
	
		if(!IntEnable(hDev, IntDealFunction))
		{   
				//�ر�Windriver����
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
		//���ó�ʼDMAд��ַ,���ȵ�
		if(!WriteBAR0(0x0c,pprDma[0]->Page[0].pPhysicalAddr)||!WriteBAR0(0x10,0,0)||!WriteBAR0(0x1c,rBlockSize,0))
		{   
			//�ر�Windriver����
			CloseDevice();
			return FALSE;
		}
		//����DMA
		addrrpointer=0;	
	}
	//����һ���߳��������ȴ��¼�
	times=0;
	stop=FALSE;
	isWork=TRUE;
	if(hfile==NULL)
	read=write=10000;//�ļ�ʹ��
	else
	read=write=0;//�ļ�ʹ��
	CreateThread(NULL,0,(LPTHREAD_START_ROUTINE)WaitForComplete,this,0,NULL);
  return TRUE; 
}
BOOL pcie::MemToFile()//���̵߳���
{
	isWriteFile=ISWRITEFILE;
	if (read==10000)
	{
		return FALSE;
	}
	if(read==addrwpointer)//addrwpointer��ʼֵ�ᱻ����Ϊ0
		return FALSE;
	else
	{
		ULONG wsize;
		if(isWriteFile==70)
		{
			WriteFile(hfile,pWbuffer[read],wBlockSize,&wsize,0);
			if(wsize!=wBlockSize)
			{
				strcpy(infor,"д�ļ�ʱ��������\n");
				return 5;//
			}
		}
		
		read=(++read)%wBnum;

	}
	return TRUE;
}

BOOL pcie::DiscToMem()//�������ļ�����д���ڴ�DMA�Ķ�������----------д���ȣ�д����׷����������DMA������׷��д
{
	if(((write+1)%rBNum)==addrrpointer)//addrrpointer��ʼֵ�ᱻ����Ϊ0
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
				strcpy(infor,"���ļ�ʱ��������\n");
				return 5;//
			}		
		}

		write=(++write)%rBNum;
		
	}
	return TRUE;

}
BOOL pcie::TransIsDown()//�������ѯʹ��
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
			//if((reg44&REALOP)==REALOP)//DDR@2,��·�͹��˼��
			if((reg44&0x00070000)==0x00070000)//DDR@2,��·�͹��˼��
			{
				return TRUE;
			}
		}
		else
		{
			//if((reg44&SIMUOP)==SIMUOP)//��·���
			if((reg44&0x00010000)==0x00010000)//��·���
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
				strcpy(infor,"PCIE��·�쳣");
			}
			//if ((reg44&0x40000000)!=0x40000000)
			if ((reg44&0x00020000)!=0x00020000)
			{
				strcat(infor,"DDR2��·�쳣");
			}
			//if ((reg44&0x20000000)!=0x20000000)
			if ((reg44&0x00040000)!=0x00040000)
			{
				strcat(infor,"������·�쳣");
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