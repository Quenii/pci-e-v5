// PCIEProject.h : main header file for the PCIEPROJECT application
//

#if !defined(AFX_PCIEPROJECT_H__0FB9AA9F_0104_4C3B_8C6D_51A05268E47D__INCLUDED_)
#define AFX_PCIEPROJECT_H__0FB9AA9F_0104_4C3B_8C6D_51A05268E47D__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CPCIEProjectApp:
// See PCIEProject.cpp for the implementation of this class
//

class CPCIEProjectApp : public CWinApp
{
public:
	CPCIEProjectApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPCIEProjectApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CPCIEProjectApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PCIEPROJECT_H__0FB9AA9F_0104_4C3B_8C6D_51A05268E47D__INCLUDED_)
