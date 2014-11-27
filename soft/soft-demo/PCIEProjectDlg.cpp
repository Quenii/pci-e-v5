// PCIEProjectDlg.cpp : implementation file
//

#include "stdafx.h"
#include "PCIEProject.h"
#include "PCIEProjectDlg.h"
#include "PcieCheck.h"
#include "RecordDlg.h"
#include "PciRecReplay.h"
#include "RecAdd.h"
#include "Chainini.h"
#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif
CPCIEProjectDlg *pPcieProject;
/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About
RecordInfor *pfirst,*plast;
class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPCIEProjectDlg dialog

CPCIEProjectDlg::CPCIEProjectDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CPCIEProjectDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CPCIEProjectDlg)
	m_recindex = _T("");
	m_reclocation = _T("");
	m_recname = _T("");
	m_recsize = _T("");
	m_recdate = _T("");
	m_recspace = _T("");
	m_rectype = _T("");
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CPCIEProjectDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CPCIEProjectDlg)
	DDX_Control(pDX, IDC_RECDELETE, m_btnrecdelet);
	DDX_Control(pDX, IDC_RECALLDELET, m_btnrecalldelet);
	DDX_Control(pDX, IDC_PCIECHECK, m_btnpciecheck);
	DDX_Control(pDX, IDC_RECREPLAY, m_btnreplay);
	DDX_Control(pDX, IDC_LIST1, m_listShow);
	DDX_Text(pDX, IDC_RECINDEX, m_recindex);
	DDX_Text(pDX, IDC_RECLOCATION, m_reclocation);
	DDX_Text(pDX, IDC_RECNAME, m_recname);
	DDX_Text(pDX, IDC_RECSIZE, m_recsize);
	DDX_Text(pDX, IDC_RECDATE, m_recdate);
	DDX_Text(pDX, IDC_DISCSPACE, m_recspace);
	DDX_Text(pDX, IDC_RECTYPE, m_rectype);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CPCIEProjectDlg, CDialog)
	//{{AFX_MSG_MAP(CPCIEProjectDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_PCIECHECK, OnPcieCheck)
	ON_MESSAGE(REFRESHLIST,RefreshList)//记录后的消息处理
	ON_MESSAGE(FIRSTLISTSHOW,FirstListShow)//记录后的消息处理
	ON_BN_CLICKED(IDOK, OnRecording)
	ON_BN_CLICKED(IDC_RECREPLAY, OnReplayBack)
	ON_NOTIFY(NM_CLICK, IDC_LIST1, OnSelectItem)
	ON_BN_CLICKED(IDC_LOCREFRESH, OnLocrefresh)
	ON_BN_CLICKED(IDC_RECDELETE, OnRecdelete)
	ON_BN_CLICKED(IDC_RECALLDELET, OnRecalldelet)
	ON_WM_CLOSE()
	ON_BN_CLICKED(IDC_FILEADD, OnFileadd)
	ON_BN_CLICKED(IDC_CHAININI, OnChainini)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPCIEProjectDlg message handlers



//该函数提供给记录模块调用.
BOOL CPCIEProjectDlg::AddRecInfor(void *pdata)
{
	RecordInfor tempdata=*((RecordInfor*)pdata);//取的数据
	char path[10];
	RecordInfor * ptemp;
	UINT freedisc;
	strcpy(path,tempdata.reclocation);
	freedisc=tempdata.freespace;
	ptemp=pfirst;
	//更新磁盘显示,主要更新磁盘空间的显示
	while (ptemp!=NULL)
	{
		if (strcmp(ptemp->reclocation,path)==0)
		{
			ptemp->freespace=freedisc;
			ptemp=ptemp->Pnext;
			continue;
		}
		ptemp=ptemp->Pnext;
	}
	//将该文件加到显示列表中去---如果没有记录

	if (pfirst==NULL)
	{
		plast=pfirst=new RecordInfor;
		memcpy(pfirst,&tempdata,sizeof(RecordInfor));
		plast->Pnext=NULL;
		
	}
	//已存在记录
	else
	{	
		plast=pfirst;
		while (plast->Pnext)
		{
			plast=plast->Pnext;
		}
		plast->Pnext=new RecordInfor;
		memcpy(plast->Pnext,&tempdata,sizeof(RecordInfor));
		plast=plast->Pnext;
		plast->Pnext=NULL;

	}
	
	return true;
}
BOOL CPCIEProjectDlg::OnInitDialog()
{
	CDialog::OnInitDialog();
	pPcieProject=this;
	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here
	//初始化显示列表的列信息
	m_listShow.SetExtendedStyle(LVS_EX_FULLROWSELECT);//某个单元选中,则全行高亮显示
	m_listShow.InsertColumn(0,"记录号",LVCFMT_LEFT, 60);
	m_listShow.InsertColumn(1, _T("记录名"),  LVCFMT_LEFT, 110);
	m_listShow.InsertColumn(2, _T("日期/时间"),  LVCFMT_LEFT, 140);
	m_listShow.InsertColumn(3, _T("记录大小(MB)"),  LVCFMT_LEFT, 100);
	m_listShow.InsertColumn(4, _T("速度(MB/s) "),  LVCFMT_LEFT, 100);
	m_listShow.InsertColumn(5, _T("位置 "),  LVCFMT_LEFT, 50);
	m_listShow.InsertColumn(6, _T("磁盘可用空间(MB) "),  LVCFMT_LEFT,120);
	m_listShow.InsertColumn(7, _T("记录类型"),  LVCFMT_LEFT,70);
	//测试部分----做几个相关测试,即点击某个列表单元,则该相应的行高亮显示
	//---向显示列表中添加项信息
	pfirst=NULL;
	plast=NULL;
	hrec=CreateFile("c:\\PcieRecInfor.txt",GENERIC_READ,0,0,OPEN_ALWAYS,0,0);
	if (hrec!=INVALID_HANDLE_VALUE)//如果保存的信息存在,需要在这里显示列表的信息,该部分不能调用AddRecInfor()函数
	{
		//CloseHandle(hrec);//这理的句柄由ReadRecInfor()函数关闭
		PostMessage(FIRSTLISTSHOW,0,0);//发送消息让消息处理函数来做这事
	}
	return TRUE;  // return TRUE  unless you set the focus to a control
}

//列表刷新函数----实际记录信息发生变化的时候调用的
void CPCIEProjectDlg::ShowListInfor()
{
	CString str;
	int index;
	RecordInfor *temp=pfirst;
	m_listShow.DeleteAllItems();
	while (temp!=NULL)
	{
		temp->recindex=m_listShow.GetItemCount();
		str.Format("%d",temp->recindex);
		//m_listShow.SetItemData(index,index);
		index=m_listShow.InsertItem(m_listShow.GetItemCount(),str);
		m_listShow.SetItemText(index,1,temp->recname);//记录名
		str.Format("%d_%d_%d_%d:%d:%d",temp->rectime.year,temp->rectime.mouth,temp->rectime.day,
			temp->rectime.hour,temp->rectime.minute,
			temp->rectime.second);
		m_listShow.SetItemText(index,2,str);//记录时间
		str.Format("%.2f",temp->recsize);
		m_listShow.SetItemText(index,3,str);//大小
		str.Format("%.2f",temp->recspeed);
		m_listShow.SetItemText(index,4,str);//速度
		m_listShow.SetItemText(index,5,temp->reclocation);//位置

		str.Format("%d",GetDiscFreeSpace(temp->reclocation));

		m_listShow.SetItemText(index,6,str);//可用空间

		m_listShow.SetItemText(index,7,temp->rectype);//可用空间
		temp=temp->Pnext;
	}
	
}
//该函数从文件读取记录信息构造链表信息,是系统启动后第一次调用的,
BOOL CPCIEProjectDlg::ReadRecInfor()
{
	RecordInfor temp;
	ULONG readbyte;
	while (1)
	{
		if (ReadFile(hrec,&temp,sizeof(RecordInfor),&readbyte,0),readbyte==sizeof(RecordInfor))
		{
			if(!DealRecFromFile(&temp))
			return FALSE;
		}
		else
		{
			CloseHandle(hrec);
			break;//读完了.
		}
	}	
	return TRUE;
}
//同时需要更新磁盘已大小已更改的信息.系统启动被自动调用
BOOL CPCIEProjectDlg::DealRecFromFile(void *pdata)
{
	char filename[20];
	RecordInfor tempdata=*((RecordInfor*)pdata);//取的数据
	//更新磁盘空间大小
	ULARGE_INTEGER FreeBytesAvailableToCaller;
	ULARGE_INTEGER TotalNumberOfBytes;
	ULARGE_INTEGER TotalNumberOfFreeBytes;
	ULARGE_INTEGER li;
	GetDiskFreeSpaceEx(
		tempdata.reclocation,                 // pointer to the directory name
		&FreeBytesAvailableToCaller, // receives the number of bytes on
		// disk available to the caller
		&TotalNumberOfBytes,    // receives the number of bytes on disk
		&TotalNumberOfFreeBytes // receives the free bytes on disk
		);
	TotalNumberOfFreeBytes.QuadPart=TotalNumberOfFreeBytes.QuadPart/(1024*1024);
	tempdata.freespace=TotalNumberOfFreeBytes.LowPart;
	strcpy(filename,tempdata.reclocation);
	strcat(filename,tempdata.recname);
	htemrec=CreateFile(filename,GENERIC_READ,0,0,OPEN_ALWAYS,0,0);
	li.LowPart=GetFileSize(htemrec,&li.HighPart);
	if(li.QuadPart==0)
	{
		CloseHandle(htemrec);

		return TRUE;
	}
	CloseHandle(htemrec);
	if (pfirst==NULL)
	{
		plast=pfirst=new RecordInfor;
		memcpy(pfirst,&tempdata,sizeof(RecordInfor));
		plast->Pnext=NULL;
	}
	//已存在记录
	else
	{
		plast->Pnext=new RecordInfor;
		memcpy(plast->Pnext,&tempdata,sizeof(RecordInfor));
		plast=plast->Pnext;
		plast->Pnext=NULL;
	}
	return TRUE;
	
}

///上面的函数已完事,


//记录后记录信息必须更新,但由于记录是采用模态对话框,所有发送消息给主界面,让主界面的这个消息处理函数处理界面信息的刷新
LRESULT CPCIEProjectDlg::RefreshList(WPARAM wParam, LPARAM lParam)//消息处理函数----用于记录后刷新显示列表的处理
{
	RecordInfor *ptemp;
	ShowListInfor();//专供记录界面记录后的列表显示
	
	
	//另外,还需要将结果写入原信息文件
	ULONG writesize;
	hrec=CreateFile("c:\\PcieRecInfor.txt",GENERIC_WRITE,0,0,CREATE_ALWAYS,0,0);	
	ptemp=pfirst;
	while (ptemp)
	{
		WriteFile(hrec,(char*)ptemp,sizeof(RecordInfor),&writesize,0);
		ptemp=ptemp->Pnext;
		
	}
	CloseHandle(hrec);
	//下面的语句是测试,呵呵

	return 1;

}
//系统启动后第一次发送的消息处理---显示列表的信息
LRESULT CPCIEProjectDlg::FirstListShow(WPARAM wParam, LPARAM lParam)
{
	RecordInfor *ptemp;
	ReadRecInfor();//这个函数主要处理第一次启动系统后的列表显示处理
	ShowListInfor();//显示列表
	//由于原来的文件里存在的信息可能不是最新的了.所以必须更新该记录信息
	ULONG writesize;
	hrec=CreateFile("c:\\PcieRecInfor.txt",GENERIC_WRITE,0,0,CREATE_ALWAYS,0,0);	
	ptemp=pfirst;
	while (ptemp)
	{
		WriteFile(hrec,ptemp,sizeof(RecordInfor),&writesize,0);
		ptemp=ptemp->Pnext;
		
	}
	CloseHandle(hrec);
	//
//	MessageBox("消息1测试","消息");

	return 1;
}

//该函数显示右边的几个编辑框的信息----------专供点击列表后响应函数调用
void CPCIEProjectDlg::ShowRecInfor()
{
	char tempstr[50];
	UINT recindex,isselected;
	isselected=m_listShow.GetSelectedCount();
	if (isselected==1)
	{
		recindex=m_listShow.GetSelectionMark();
		m_listShow.GetItemText(recindex,0,tempstr,50);
		m_recindex=tempstr;
		m_listShow.GetItemText(recindex,1,tempstr,50);
		m_recname=tempstr;
		m_listShow.GetItemText(recindex,2,tempstr,50);
		m_recdate=tempstr;
		m_listShow.GetItemText(recindex,3,tempstr,50);
		m_recsize=tempstr;
		m_listShow.GetItemText(recindex,5,tempstr,50);
		m_reclocation=tempstr;
		m_listShow.GetItemText(recindex,4,tempstr,50);
		m_recspeed=tempstr;//速度;用于在回放时的显示;
		//磁盘空间信息处理
		m_listShow.GetItemText(recindex,6,tempstr,50);
		m_recspace=tempstr;
		m_listShow.GetItemText(recindex,7,tempstr,50);
		m_rectype=tempstr;
		m_btnreplay.EnableWindow(TRUE);
		m_btnrecdelet.EnableWindow(TRUE);
		UpdateData(FALSE);

		
		
	}
	else
	{
		m_recindex="";
		m_recname="";
		m_recdate="";
		m_recsize="";
		m_reclocation="";
		m_recspeed="";
		//下面是磁盘空间的处理
		m_recspace="";
		m_btnreplay.EnableWindow(FALSE);
		m_btnrecdelet.EnableWindow(FALSE);

		UpdateData(FALSE);

	}
	
}

void CPCIEProjectDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CPCIEProjectDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CPCIEProjectDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

//PCIE检测,即发现PCIE设备
void CPCIEProjectDlg::OnPcieCheck() 
{
	// TODO: Add extra initialization here
	if (pci_e.OpenDevice(0x10ee,7)==FALSE)
	{
		MessageBox("设备打开失败,无指定设备存在","错误信息");
		return ;
	}
	CPcieCheck pciecheck;
	pciecheck.DoModal();
	// TODO: Add your control notification handler code here
	
}
//记录数据对话框
void CPCIEProjectDlg::OnRecording() 
{
	CRecordDlg dlg;
	dlg.DoModal();
	// TODO: Add your control notification handler code here
	
}
//回放数据对话框
void CPCIEProjectDlg::OnReplayBack() 
{
	if (m_recname=="")
	{
		MessageBox("当前您没有选择一条有效记录,请选择一条记录后重试","提示");
		return ;
	}
	CPciRecReplay dlg;
	dlg.DoModal();
	// TODO: Add your control notification handler code here
}

void CPCIEProjectDlg::OnSelectItem(NMHDR* pNMHDR, LRESULT* pResult) 
{
	// TODO: Add your control notification handler code here
	ShowRecInfor();
	*pResult = 0;
}






void CPCIEProjectDlg::OnLocrefresh() 
{
	ShowListInfor();//单纯的显示链表里面的内容
	
}


//删除单条信息
void CPCIEProjectDlg::OnRecdelete() 
{
    if (m_recindex=="")
    {
		MessageBox("请选择有效记录后重试！","删除文件提示");
		return ;
    }
	if (MessageBox("您确定要删除记录号为:"+m_recindex+" 的文件,并从磁盘上将这些文件删除?","删除文件提示",MB_ICONQUESTION|MB_YESNO)==IDNO)
	return;
	RecordInfor *phead,*psecond,*ptemp;
	char filename[20];
	phead=pfirst;
	if (phead->recindex==(UINT)atoi(m_recindex))
	{
		strcpy(filename,phead->reclocation);
		strcat(filename,phead->recname);
		pfirst=pfirst->Pnext;
		DeleteFile(filename);
		delete phead;
		if (pfirst==NULL)
		{
			plast=NULL;
		}
	}
	else
	{
		while (phead->Pnext->recindex!=(UINT)atoi(m_recindex))
		{
			phead=phead->Pnext;
		}
		psecond=phead->Pnext->Pnext;
		strcpy(filename,phead->Pnext->reclocation);
		strcat(filename,phead->Pnext->recname);
		DeleteFile(filename);
		delete phead->Pnext;
		phead->Pnext=psecond;
		if (psecond==NULL)
		{
			plast=phead;
		}

	}
	ShowListInfor();
	ULONG writesize;
	hrec=CreateFile("c:\\PcieRecInfor.txt",GENERIC_WRITE,0,0,CREATE_ALWAYS,0,0);	
	ptemp=pfirst;
	while (ptemp)
	{
		
		WriteFile(hrec,ptemp,sizeof(RecordInfor),&writesize,0);
		ptemp=ptemp->Pnext;
		
	}
	CloseHandle(hrec);
	m_recindex="";
	m_recname="";
	m_recdate="";
	m_recsize="";
	m_reclocation="";
	m_recspeed="";
	//下面是磁盘空间的处理
	m_recspace="";
}
//删除所有文件
void CPCIEProjectDlg::OnRecalldelet() 
{

	if (MessageBox("您确定要删除所有显示列表里显示的文件信息,并从磁盘上将这些文件删除?","删除文件提示",MB_ICONQUESTION|MB_YESNO)==IDNO)
	return;
	RecordInfor *phead,*psecond;
	char filename[20];
	phead=pfirst;
	while (phead)
	{
		psecond=phead->Pnext;
		strcpy(filename,phead->reclocation);
		strcat(filename,phead->recname);	
		DeleteFile(filename);
		delete phead;
		phead=psecond;
	}
	pfirst=NULL;
	ShowListInfor();// TODO: Add your control notification handler code here
	hrec=CreateFile("c:\\PcieRecInfor.txt",GENERIC_WRITE,0,0,CREATE_ALWAYS,0,0);
	CloseHandle(hrec);
	
}

void CPCIEProjectDlg::DeleteChain()
{
	RecordInfor *ptemp;
	ptemp=pfirst;
	while (ptemp)
	{
		pfirst=ptemp->Pnext;
		delete ptemp;
		ptemp=pfirst;
	}
}

UINT CPCIEProjectDlg::GetDiscFreeSpace(char *disc)
{
	ULARGE_INTEGER FreeBytesAvailableToCaller;
	ULARGE_INTEGER TotalNumberOfBytes;
	ULARGE_INTEGER TotalNumberOfFreeBytes;
	GetDiskFreeSpaceEx(
		disc,                 // pointer to the directory name
		&FreeBytesAvailableToCaller, // receives the number of bytes on
		&TotalNumberOfBytes,    // receives the number of bytes on disk
		&TotalNumberOfFreeBytes // receives the free bytes on disk
		);
	TotalNumberOfFreeBytes.QuadPart=TotalNumberOfFreeBytes.QuadPart/(1024*1024);
	return TotalNumberOfFreeBytes.LowPart;
}

void CPCIEProjectDlg::OnClose() 
{
	// TODO: Add your message handler code here and/or call default
	pci_e.CloseDevice();	
	CDialog::OnClose();
}

void CPCIEProjectDlg::OnCancel() 
{
	// TODO: Add extra cleanup here

	pci_e.CloseDevice();
	CDialog::OnCancel();
}

void CPCIEProjectDlg::OnFileadd() 
{
	CRecAdd dlg;
	dlg.DoModal();
	// TODO: Add your control notification handler code here
	
}

void CPCIEProjectDlg::OnChainini() 
{
	CChainini dlg;
	dlg.DoModal();
	// TODO: Add your control notification handler code here
	
}
