#ifndef PCI_E_H 
#define PCI_E_H
//#include <windows.h>
#include <windrvr.h>
#include "wdc_lib.h"
//#include <wdc_defs.h>
//#include <utils.h>
//������,�������ÿռ�ĺ�

#define	VENDORID   0
#define DEVICEID   2
#define COMRG      4
#define STATUSRG   6
#define REVERSION  8
#define CLASSCODE  9
#define CACHESIZE  12
#define LATENCY    13
#define HEADTYPE   14
#define BIST       15
#define BAR0       16
#define BAR1       20
#define BAR2       24
#define BAR3       28
#define BAR4       32
#define BAR5       36
#define CIS        40
#define SUBVENDER  44
#define SUBDEVICE  46
#define EXTENDROM  48
#define FPOINTER   52
#define INTLINE    60
#define INTPIN     61
#define MINGNT     62
#define MAXLATENCY 63

#define ISIO       1
#define BAR64      10
#define BASEMEM32  0xFFFFFF80
#define BASEMEN64  0xFFFFFFFFFFFFFF80
#define PCIVENDORID 0x10ee                                              //���̺�
#define PCIDEVICEID	0x7								                    //�豸��
#define LICENSESTR	"6C3CC2BFF76637EC558F0D4D088AF4534612762D.Sunsoon"  //����֤��

// 70:write disc   71:no write
#define ISWRITEFILE 70
//#define ISWRITEFILE 71

// 80:read disc   81:no read
#define ISREADFILE  80
//#define ISREADFILE  81


typedef struct
{
    DWORD dwCounter; /* Number of interrupts received */
    DWORD dwLost;    /* Number of interrupts not yet handled */
    WD_INTERRUPT_WAIT_RESULT waitResult; /* See WD_INTERRUPT_WAIT_RESULT values in windrvr.h */
} PCIINT_RESULT;

/* �жϺ���ָ�붨�� diagnostics interrupt handler function type */
typedef void (*PCIINT_HANDLER)(WDC_DEVICE_HANDLE hDev,PCIINT_RESULT *pIntResult);
/* �¼���������ָ�붨�� diagnostics plug-and-play and power management events handler function type */
typedef void (*PCIEVENT_HANDLER)(WDC_DEVICE_HANDLE hDev,DWORD dwAction);
/*�豸�����Ľṹ�嶨��*/
typedef struct {
    WD_TRANSFER      *pIntTransCmds;
    PCIINT_HANDLER   funcDiagIntHandler;
    PCIEVENT_HANDLER funcDiagEventHandler;
} PCIDEV_CTX, *PPCIDEV_CTX;
//�ඨ��
class pcie
{
public:
	BOOL ChainIniCheck();
	BOOL IsDeviceOpen();
	BOOL FPGAReset();
	BOOL DiscToMem();
	pcie();
	void GetLastInfo(char * info);                       //��ȡ�κ�������ʧ�ܵ���Ϣ
	BOOL ReadCfg(DWORD offset,UINT*outdata,UINT numbyte);//���ڶ�ȡ���ÿռ��������Ϣ--�����ϲ���
	//����1Ϊ���涨����κ�һ���꣬����2���պ����ķ������ݣ�����3����Ҫ��ȡ���ֽ�������ȡ1��2��4

	BOOL OpenDevice(DWORD vendorid,DWORD deviceid);      //���豸---������TRUE�����ɹ�������FALSE������ʧ�ܣ���ʱ�������κδ���
    virtual BOOL ReadBAR0(DWORD offset,UINT*outdata,UINT numbyte);
	virtual BOOL WriteBAR0(DWORD offset,UINT indata,UINT numbyte);
	virtual BOOL DMAReadMenAlloc(UINT menBlocknum,UINT blocksize);
	virtual BOOL DMAWriteMenAlloc(UINT menBlocknum,UINT blocksize);
	virtual BOOL IntEnable(WDC_DEVICE_HANDLE hDev, PCIINT_HANDLER funcIntHandler);
	virtual BOOL StartDMA(BOOL wmen,HANDLE hf,BOOL isrealop,HANDLE finishEven);
	virtual void CloseDevice();
	UINT GetPhsicalWBufferAdd(UINT index);
	UINT GetPhsicalRBufferAdd(UINT index);
	void StopDMA();
	void SetTransBlkNum(UINT num);
	UINT GetTransBlock();
	UINT GetTimes();
	BOOL TransIsDown();
	//BOOL MemToDevice(HANDLE hf);
	BOOL MemToFile();
	//  DMAʹ��
	HANDLE hev;
	BOOL isWork,stop;
	UINT areadyTran,times;                   //����1���Ѿ���ɵĴ������������2�����һ�δ�����������ʱ��
	UINT tranBlock,addrwpointer,addrrpointer;//����1��������ܿ���������2��д��������Ӧ�����׵�ַ����������3��������������ַ����
	UINT rBlockSize,wBlockSize,rBNum,wBnum;//����1������������С������2��д��������С������3��������������������4��д����������
	BOOL wmemory,intUse;
   //�ļ�ʹ��
	UINT read,write;
	HANDLE hfile;
	BOOL isreal;
	int isWriteFile;
	int isReadFile;

protected:
private:
	WD_DMA* pprDma[16];
	WD_DMA* ppwDma[16];
	PVOID pRbuffer[16];
	PVOID pWbuffer[16];
	char infor[1024];//������Ϣ��������һ�β���ʧ�ܵ���Ϣ
	WDC_DEVICE_HANDLE hDev;        //���windriver�ں��е��豸���������ַ
	WDC_PCI_SCAN_RESULT scanResult;//���ɨ����
	WD_PCI_CARD_INFO deviceInfo;   //���豸�ľ�����Ϣ
	PPCIDEV_CTX    pDevCtx;        //��ָ����ָ�ռ����ڴ���豸����������
	WD_TRANSFER *pTrans;

};
#endif