#ifdef MATLAB_MEX_FILE
    #include "mex.h"
#endif

#include "iostream"
using namespace std;

char MessageBuffer[4096];

// Implementation dependent
void MessageLog(const char* className, const char* methodName, const char* errorMessage)
{
	strcpy(MessageBuffer, className);
	strcat(MessageBuffer, "::");
	strcat(MessageBuffer, methodName);
	strcat(MessageBuffer, " ");
	strcat(MessageBuffer, errorMessage);
	
#ifdef MATLAB_MEX_FILE
    mexErrMsgTxt(MessageBuffer);
#else
	cout << endl << MessageBuffer << endl;
#endif
}

//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.