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
	ON_MESSAGE(REFRESHLIST,RefreshList)//��¼�����Ϣ����
	ON_MESSAGE(FIRSTLISTSHOW,FirstListShow)//��¼�����Ϣ����
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



//�ú����ṩ����¼ģ�����.
BOOL CPCIEProjectDlg::AddRecInfor(void *pdata)
{
	RecordInfor tempdata=*((RecordInfor*)pdata);//ȡ������
	char path[10];
	RecordInfor * ptemp;
	UINT freedisc;
	strcpy(path,tempdata.reclocation);
	freedisc=tempdata.freespace;
	ptemp=pfirst;
	//���´�����ʾ,��Ҫ���´��̿ռ����ʾ
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
	//�����ļ��ӵ���ʾ�б���ȥ---���û�м�¼

	if (pfirst==NULL)
	{
		plast=pfirst=new RecordInfor;
		memcpy(pfirst,&tempdata,sizeof(RecordInfor));
		plast->Pnext=NULL;
		
	}
	//�Ѵ��ڼ�¼
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
	//��ʼ����ʾ�б������Ϣ
	m_listShow.SetExtendedStyle(LVS_EX_FULLROWSELECT);//ĳ����Ԫѡ��,��ȫ�и�����ʾ
	m_listShow.InsertColumn(0,"��¼��",LVCFMT_LEFT, 60);
	m_listShow.InsertColumn(1, _T("��¼��"),  LVCFMT_LEFT, 110);
	m_listShow.InsertColumn(2, _T("����/ʱ��"),  LVCFMT_LEFT, 140);
	m_listShow.InsertColumn(3, _T("��¼��С(MB)"),  LVCFMT_LEFT, 100);
	m_listShow.InsertColumn(4, _T("�ٶ�(MB/s) "),  LVCFMT_LEFT, 100);
	m_listShow.InsertColumn(5, _T("λ�� "),  LVCFMT_LEFT, 50);
	m_listShow.InsertColumn(6, _T("���̿��ÿռ�(MB) "),  LVCFMT_LEFT,120);
	m_listShow.InsertColumn(7, _T("��¼����"),  LVCFMT_LEFT,70);
	//���Բ���----��������ز���,�����ĳ���б�Ԫ,�����Ӧ���и�����ʾ
	//---����ʾ�б����������Ϣ
	pfirst=NULL;
	plast=NULL;
	hrec=CreateFile("c:\\PcieRecInfor.txt",GENERIC_READ,0,0,OPEN_ALWAYS,0,0);
	if (hrec!=INVALID_HANDLE_VALUE)//����������Ϣ����,��Ҫ��������ʾ�б����Ϣ,�ò��ֲ��ܵ���AddRecInfor()����
	{
		//CloseHandle(hrec);//����ľ����ReadRecInfor()�����ر�
		PostMessage(FIRSTLISTSHOW,0,0);//������Ϣ����Ϣ��������������
	}
	return TRUE;  // return TRUE  unless you set the focus to a control
}

//�б�ˢ�º���----ʵ�ʼ�¼��Ϣ�����仯��ʱ����õ�
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
		m_listShow.SetItemText(index,1,temp->recname);//��¼��
		str.Format("%d_%d_%d_%d:%d:%d",temp->rectime.year,temp->rectime.mouth,temp->rectime.day,
			temp->rectime.hour,temp->rectime.minute,
			temp->rectime.second);
		m_listShow.SetItemText(index,2,str);//��¼ʱ��
		str.Format("%.2f",temp->recsize);
		m_listShow.SetItemText(index,3,str);//��С
		str.Format("%.2f",temp->recspeed);
		m_listShow.SetItemText(index,4,str);//�ٶ�
		m_listShow.SetItemText(index,5,temp->reclocation);//λ��

		str.Format("%d",GetDiscFreeSpace(temp->reclocation));

		m_listShow.SetItemText(index,6,str);//���ÿռ�

		m_listShow.SetItemText(index,7,temp->rectype);//���ÿռ�
		temp=temp->Pnext;
	}
	
}
//�ú������ļ���ȡ��¼��Ϣ����������Ϣ,��ϵͳ�������һ�ε��õ�,
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
			break;//������.
		}
	}	
	return TRUE;
}
//ͬʱ��Ҫ���´����Ѵ�С�Ѹ��ĵ���Ϣ.ϵͳ�������Զ�����
BOOL CPCIEProjectDlg::DealRecFromFile(void *pdata)
{
	char filename[20];
	RecordInfor tempdata=*((RecordInfor*)pdata);//ȡ������
	//���´��̿ռ��С
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
	//�Ѵ��ڼ�¼
	else
	{
		plast->Pnext=new RecordInfor;
		memcpy(plast->Pnext,&tempdata,sizeof(RecordInfor));
		plast=plast->Pnext;
		plast->Pnext=NULL;
	}
	return TRUE;
	
}

///����ĺ���������,


//��¼���¼��Ϣ�������,�����ڼ�¼�ǲ���ģ̬�Ի���,���з�����Ϣ��������,��������������Ϣ���������������Ϣ��ˢ��
LRESULT CPCIEProjectDlg::RefreshList(WPARAM wParam, LPARAM lParam)//��Ϣ������----���ڼ�¼��ˢ����ʾ�б�Ĵ���
{
	RecordInfor *ptemp;
	ShowListInfor();//ר����¼�����¼����б���ʾ
	
	
	//����,����Ҫ�����д��ԭ��Ϣ�ļ�
	ULONG writesize;
	hrec=CreateFile("c:\\PcieRecInfor.txt",GENERIC_WRITE,0,0,CREATE_ALWAYS,0,0);	
	ptemp=pfirst;
	while (ptemp)
	{
		WriteFile(hrec,(char*)ptemp,sizeof(RecordInfor),&writesize,0);
		ptemp=ptemp->Pnext;
		
	}
	CloseHandle(hrec);
	//���������ǲ���,�Ǻ�

	return 1;

}
//ϵͳ�������һ�η��͵���Ϣ����---��ʾ�б����Ϣ
LRESULT CPCIEProjectDlg::FirstListShow(WPARAM wParam, LPARAM lParam)
{
	RecordInfor *ptemp;
	ReadRecInfor();//���������Ҫ�����һ������ϵͳ����б���ʾ����
	ShowListInfor();//��ʾ�б�
	//����ԭ�����ļ�����ڵ���Ϣ���ܲ������µ���.���Ա�����¸ü�¼��Ϣ
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
//	MessageBox("��Ϣ1����","��Ϣ");

	return 1;
}

//�ú�����ʾ�ұߵļ����༭�����Ϣ----------ר������б����Ӧ��������
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
		m_recspeed=tempstr;//�ٶ�;�����ڻط�ʱ����ʾ;
		//���̿ռ���Ϣ����
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
		//�����Ǵ��̿ռ�Ĵ���
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

//PCIE���,������PCIE�豸
void CPCIEProjectDlg::OnPcieCheck() 
{
	// TODO: Add extra initialization here
	if (pci_e.OpenDevice(0x10ee,7)==FALSE)
	{
		MessageBox("�豸��ʧ��,��ָ���豸����","������Ϣ");
		return ;
	}
	CPcieCheck pciecheck;
	pciecheck.DoModal();
	// TODO: Add your control notification handler code here
	
}
//��¼���ݶԻ���
void CPCIEProjectDlg::OnRecording() 
{
	CRecordDlg dlg;
	dlg.DoModal();
	// TODO: Add your control notification handler code here
	
}
//�ط����ݶԻ���
void CPCIEProjectDlg::OnReplayBack() 
{
	if (m_recname=="")
	{
		MessageBox("��ǰ��û��ѡ��һ����Ч��¼,��ѡ��һ����¼������","��ʾ");
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
	ShowListInfor();//��������ʾ�������������
	
}


//ɾ��������Ϣ
void CPCIEProjectDlg::OnRecdelete() 
{
    if (m_recindex=="")
    {
		MessageBox("��ѡ����Ч��¼�����ԣ�","ɾ���ļ���ʾ");
		return ;
    }
	if (MessageBox("��ȷ��Ҫɾ����¼��Ϊ:"+m_recindex+" ���ļ�,���Ӵ����Ͻ���Щ�ļ�ɾ��?","ɾ���ļ���ʾ",MB_ICONQUESTION|MB_YESNO)==IDNO)
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
	//�����Ǵ��̿ռ�Ĵ���
	m_recspace="";
}
//ɾ�������ļ�
void CPCIEProjectDlg::OnRecalldelet() 
{

	if (MessageBox("��ȷ��Ҫɾ��������ʾ�б�����ʾ���ļ���Ϣ,���Ӵ����Ͻ���Щ�ļ�ɾ��?","ɾ���ļ���ʾ",MB_ICONQUESTION|MB_YESNO)==IDNO)
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
