// RecAdd.cpp : implementation file
//

#include "stdafx.h"
#include "PCIEProject.h"
#include "RecAdd.h"
#include "PCIEProjectDlg.h"
#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CRecAdd dialog
extern CPCIEProjectDlg*pPcieProject;
extern RecordInfor *pfirst;

CRecAdd::CRecAdd(CWnd* pParent /*=NULL*/)
	: CDialog(CRecAdd::IDD, pParent)
{
	//{{AFX_DATA_INIT(CRecAdd)
	m_edit2 = _T("");
	m_edit1 = _T("");
	m_information = _T("");
	//}}AFX_DATA_INIT
}
void CRecAdd::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CRecAdd)
	DDX_Text(pDX, IDC_EDIT1, m_edit2);
	DDX_Text(pDX, IDC_EDIT2, m_edit1);
	DDX_Text(pDX, IDC_STATIC1, m_information);
	//}}AFX_DATA_MAP
}
BEGIN_MESSAGE_MAP(CRecAdd, CDialog)
	//{{AFX_MSG_MAP(CRecAdd)
	ON_WM_CLOSE()
	ON_BN_CLICKED(IDC_LIULAN, OnLiulan)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CRecAdd message handlers

void CRecAdd::OnOK() 
{
	RecordInfor recinf;
	CTime times;
	CString loc,filename;
	RecordInfor *temp;
	temp=pfirst;
	//UpdateData(TRUE);
	if (m_edit2=="")
	{
		MessageBox("�ļ���Ϊ�գ�����ѡ���ļ�","��ʾ");
		return;
	}
	if (atoi(m_edit1)<1)
	{
		MessageBox("�ļ�С��1MB���������","��ʾ");
		return;
	}
	loc=m_edit2.Mid(0,3);
	filename=m_edit2.Mid(3,m_edit2.GetLength()-3);
	while (temp)
	{
		if ((strcmp(temp->reclocation,loc.GetBuffer(0))==0)&&(strcmp(temp->recname,filename.GetBuffer(0))==0))
		{
			MessageBox("���ļ��Ѵ��ڣ��������","��ʾ");
			return ;
		}
		temp=temp->Pnext;
	}
	//��ʼ����ļ���
	m_information="���ڴ����ļ���ӣ����Ե�...";
	times=CTime::GetCurrentTime();
	recinf.rectime.day=times.GetDay();
	recinf.rectime.year=times.GetYear();
	recinf.rectime.mouth=times.GetMonth();
	recinf.rectime.hour=times.GetHour();
	recinf.rectime.minute=times.GetMinute();
	recinf.rectime.second=times.GetSecond();
	strcpy(recinf.reclocation,loc.GetBuffer(0));
	strcpy(recinf.recname,filename.GetBuffer(0));
	recinf.freespace=pPcieProject->GetDiscFreeSpace(loc.GetBuffer(0));
	recinf.recspeed=0;
	recinf.recsize=(float)atoi(m_edit1);
	strcpy(recinf.rectype,"���ؼ�¼");
	recinf.Pnext=NULL;
	pPcieProject->AddRecInfor(&recinf);
	needshow=TRUE;
	m_edit2="";
	m_edit1="";
	m_information="�ļ������ϣ���Ҫ��������ļ����������...����Ҫ�˳�������˳�";
	UpdateData(FALSE);
	// TODO: Add extra validation here
	
//	CDialog::OnOK();
}

void CRecAdd::OnCancel() 
{
	// TODO: Add extra cleanup here
	if (needshow)
	{
		pPcieProject->PostMessage(REFRESHLIST,0,0);
	}
	CDialog::OnCancel();
}

void CRecAdd::OnClose() 
{
	// TODO: Add your message handler code here and/or call default
	if (needshow)
	{
		pPcieProject->PostMessage(REFRESHLIST,0,0);
	}
	CDialog::OnClose();
}

void CRecAdd::OnLiulan() 
{
	// TODO: Add your control notification handler code here
	LARGE_INTEGER li;
	UINT sourceSize;
	HANDLE tempHandle;
	CFileDialog dlg(TRUE); //�õ��ļ�·�����ļ���
	int ret=dlg.DoModal(); 
	if(ret==IDOK) 
	{	//m_FileName=dlg.GetFileName();	
		m_edit2=dlg.GetPathName(); 
		tempHandle=CreateFile(m_edit2.GetBuffer(0), GENERIC_READ,0, NULL, OPEN_ALWAYS, 0, NULL );
		if(tempHandle == INVALID_HANDLE_VALUE )
		{  
			MessageBox("�ļ���ʧ��");
			CloseHandle(tempHandle);
			return ;
		}
		li.LowPart =GetFileSize(tempHandle,(unsigned long *)&(li.HighPart)); //δ���ļ��Ĵ�С
		li.QuadPart=li.QuadPart/(1024*1024);
		sourceSize=li.LowPart;
		m_edit1.Format("%d",sourceSize);
		CloseHandle(tempHandle);
	}
	else
	{
		m_edit1="";
		m_edit2="";
	}
	UpdateData(FALSE);
}

BOOL CRecAdd::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	// TODO: Add extra initialization here
	needshow=FALSE;
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}
