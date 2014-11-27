#ifndef PCI_E_H 
#define PCI_E_H
//#include <windows.h>
#include <windrvr.h>
#include "wdc_lib.h"
//#include <wdc_defs.h>
//#include <utils.h>
//测试用,定义配置空间的宏

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
#define PCIVENDORID 0x10ee                                              //厂商号
#define PCIDEVICEID	0x7								                    //设备号
#define LICENSESTR	"6C3CC2BFF76637EC558F0D4D088AF4534612762D.Sunsoon"  //许可证号

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

/* 中断函数指针定义 diagnostics interrupt handler function type */
typedef void (*PCIINT_HANDLER)(WDC_DEVICE_HANDLE hDev,PCIINT_RESULT *pIntResult);
/* 事件触发函数指针定义 diagnostics plug-and-play and power management events handler function type */
typedef void (*PCIEVENT_HANDLER)(WDC_DEVICE_HANDLE hDev,DWORD dwAction);
/*设备上下文结构体定义*/
typedef struct {
    WD_TRANSFER      *pIntTransCmds;
    PCIINT_HANDLER   funcDiagIntHandler;
    PCIEVENT_HANDLER funcDiagEventHandler;
} PCIDEV_CTX, *PPCIDEV_CTX;
//类定义
class pcie
{
public:
	BOOL ChainIniCheck();
	BOOL IsDeviceOpen();
	BOOL FPGAReset();
	BOOL DiscToMem();
	pcie();
	void GetLastInfo(char * info);                       //获取任何最后操作失败的信息
	BOOL ReadCfg(DWORD offset,UINT*outdata,UINT numbyte);//用于读取配置空间的数据信息--基本上不用
	//参数1为上面定义的任何一个宏，参数2接收函数的返回数据，参数3表明要读取的字节数，可取1，2，4

	BOOL OpenDevice(DWORD vendorid,DWORD deviceid);      //打开设备---若返回TRUE表明成功，返回FALSE无需则失败，此时无需做任何处理
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
	//  DMA使用
	HANDLE hev;
	BOOL isWork,stop;
	UINT areadyTran,times;                   //变量1：已经完成的传输块数，变量2：完成一次传输任务所用时间
	UINT tranBlock,addrwpointer,addrrpointer;//变量1：传输的总块数，变量2：写缓冲区对应物理首地址索引，变量3：读缓冲物理地址索引
	UINT rBlockSize,wBlockSize,rBNum,wBnum;//变量1：读缓冲区大小，变量2：写缓冲区大小，变量3：读缓冲区个数，变量4：写缓冲区个数
	BOOL wmemory,intUse;
   //文件使用
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
	char infor[1024];//操作信息，存放最近一次操作失败的信息
	WDC_DEVICE_HANDLE hDev;        //存放windriver内核中的设备句柄变量地址
	WDC_PCI_SCAN_RESULT scanResult;//存放扫描结果
	WD_PCI_CARD_INFO deviceInfo;   //打开设备的具体信息
	PPCIDEV_CTX    pDevCtx;        //该指针所指空间用于存放设备上下文数据
	WD_TRANSFER *pTrans;

};
#endif