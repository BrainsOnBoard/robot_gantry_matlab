//  Vers  Date      By       Notes
//  ----  ----      --       -----
//  1.0   6/28/2000 GENE LIN Created
//

#include <windows.h> // Added by Chris Johnson August 2012

#ifndef PCI1240_MIC3240_HEADER_PUBLIC
#define PCI1240_MIC3240_HEADER_PUBLIC

#define PUBLIC  extern
#define PRIVATE static

#if !defined(_WIN31)
    #define FEXPORT __declspec (dllexport)
    #define FTYPE  CALLBACK
#else
    #define FEXPORT extern
    #define FTYPE  FAR PASCAL
#endif

#define DOUBLE double

//-----------------------------------------------------------------------------
//		Define for examples
//-----------------------------------------------------------------------------
#ifndef _MCX314Info
/************************************************************************
   Define Global Value
************************************************************************/
#define CW                      0
#define CCW                     1
#define ImmediateStop           0
#define SlowStop                1
#define RelativeCoordinate      0
#define AbsoluteCoordinate      1
#define TCurveAcceleration      0
#define SCurveAcceleration      1
//***********************************************************************
// Define Hardware Register Address
//***********************************************************************
// These hardware register address can be used in P1240_InpWord and P1240_OutpWord
#define HW_WR0                0x00
#define HW_WR1                0x02
#define HW_WR2                0x04
#define HW_WR3                0x06
#define HW_WR4                0x08
#define HW_WR5                0x0A
#define HW_WR6                0x0C
#define HW_WR7                0x0E
#define HW_RR0                0x00
#define HW_RR1                0x02
#define HW_RR2                0x04
#define HW_RR3                0x06
#define HW_RR4                0x08
#define HW_RR5                0x0A
#define HW_RR6                0x0C
#define HW_RR7                0x0E
/************************************************************************
   Define Register ID
************************************************************************/
#define Rcnt                    0x0100          /* Real position counter */
#define Lcnt                    0x0101          /* Logical position counter */
#define Pcmp                    0x0102          /* P direction compare register */
#define Ncmp                    0x0103          /* N direction compare register */
#define Pnum                    0x0104          /* Pulse number */

#define CurV					0x0105			/* current logical speed */  
#define CurAC					0x0106			/* current logical acc	*/

#define SLDN_STOP               0x0026			
#define IMME_STOP               0x0027

#define WR3_OUTSL               0x0080

#define RESET					0x8000
#define RR0                     0x0200          
#define RR1                     0x0202
#define RR2                     0x0204
#define RR3                     0x0206
#define RR4                     0x0208
#define RR5                     0x020A
#define RR6                     0x020C
#define RR7                     0x020E

#define WR0                     0x0210
#define WR1                     0x0212
#define WR2                     0x0214
#define WR3                     0x0216
#define WR4                     0x0218
#define WR5                     0x021A
#define WR6                     0x021C
#define WR7                     0x021E

#define RG                      0x0300
#define SV                      0x0301
#define DV                      0x0302
#define MDV                     0x0303
#define AC                      0x0304
#define DC                      0x0305
#define AK                      0x0306
#define PLmt                    0x0307
#define NLmt                    0x0308
#define HomeOffset              0x0309
#define HomeMode                0x030A
#define HomeType                0x030B
#define HomeP0_Dir              0x030C
#define HomeP0_Speed            0x030D
#define HomeP1_Dir              0x030E
#define HomeP1_Speed            0x030F
#define HomeP2_Dir              0x0310
#define HomeOffset_Speed        0x0311
#define RWSN					0x0312

/************************************************************************
   Define Operation Axis
************************************************************************/
#define IPO_Axis				0x00	
#define X_Axis                  0x01
#define Y_Axis                  0x02
#define Z_Axis                  0x04
#define U_Axis                  0x08
#define XY_Axis                 0x03
#define XZ_Axis                 0x05
#define XU_Axis                 0x09
#define YZ_Axis                 0x06
#define YU_Axis                 0x0A
#define ZU_Axis                 0x0C
#define XYZ_Axis                0x07
#define XYU_Axis                0x0B
#define XZU_axis                0x0D
#define YZU_Axis                0x0E
#define XYZU_Axis               0x0F

/************************************************************************
   Path type for continue moving
************************************************************************/
#define IPO_L2                  0x0030
#define IPO_L3                  0x0031
#define IPO_CW                  0x0032
#define IPO_CCW                 0x0134

/************************************************************************
   Return Code
************************************************************************/
#define BoardNumErr             0x0001	
#define CreateKernelDriverFail  0x0002	//internal system error
#define CallKernelDriverFail    0x0003  //internal system error
#define RegistryOpenFail        0x0004	//Open registry file fail
#define RegistryReadFail        0x0005	//Read registry file fail
#define AxisNumErr              0x0006
#define UnderRGErr              0x0007
#define OverRGErr               0x0008
#define UnderSVErr              0x0009
#define OverSVErr               0x000a
#define OverMDVErr              0x000b
#define UnderDVErr              0x000c
#define OverDVErr               0x000d
#define UnderACErr              0x000e
#define OverACErr               0x000f
#define UnderAKErr              0x0010
#define OverAKErr               0x0011
#define OverPLmtErr             0x0012
#define OverNLmtErr             0x0013
#define MaxMoveDistErr          0x0014
#define AxisDrvBusy             0x0015
#define RegUnDefine             0x0016
#define ParaValueErr            0x0017
#define ParaValueOverRange      0x0018
#define ParaValueUnderRange     0x0019
#define AxisHomeBusy            0x001a
#define AxisExtBusy             0x001b
#define RegistryWriteFail       0x001c
#define ParaValueOverErr        0x001d
#define ParaValueUnderErr       0x001e
#define OverDCErr               0x001f
#define UnderDCErr              0x0020
#define UnderMDVErr             0x0021
#define RegistryCreateFail      0x0022
#define CreateThreadErr         0x0023		//internal system fail
#define HomeSwStop		        0x0024		//P1240HomeStatus
#define ChangeSpeedErr          0x0025
#define DOPortAsDriverStatus    0x0026

#define OpenEventFail           0x0030		//Internal system fail
#define DeviceCloseErr			0x0032		//Internal system fail

#define HomeEMGStop             0x0040		//P1240HomeStatus
#define HomeLMTPStop            0x0041		//P1240HomeStatus
#define HomeLMTNStop            0x0042		//P1240HomeStatus
#define HomeALARMStop           0x0043		//P1240HomeStatus

#define AllocateBufferFail				0x0050
#define BufferReAllocate				0x0051
#define FreeBufferFail					0x0052
#define FirstPointNumberFail			0x0053	
#define PointNumExceedAllocatedSize		0x0054
#define BufferNoneAllocate				0x0055
#define SequenceNumberErr				0x0056	
#define PathTypeErr						0x0057
#define PathTypeMixErr					 0x0060
#define BufferDataNotEnough				0x0061

#define ChangePositionErr        0x0027    //Change position error


/************************************************************************
   External mode
************************************************************************/
#define JOGDisable              0x00
#define JOGSelfAxis             0x01
#define JOGSelect_XAxis         0x02
#define JOGSelect_YAxis         0x03
#define JOGConnect_XAxis        0x04
#define JOGConnect_YAxis        0x05
#define JOGConnect_ZAxis        0x06
#define JOGConnect_UAxis        0x07
#define HandWheelDisable        0x08
#define HandWheelSelfAxis       0x09
#define HandWheelSelect_XAxis   0x0a
#define HandWheelSelect_YAxis   0x0b
#define HandWheelFrom_XAxis     0x0c
#define HandWheelFrom_YAxis     0x0d
#define HandWheelFrom_ZAxis     0x0e
#define HandWheelFrom_UAxis     0x0f


// Line Interplation( 2 axes )  
//		- dwEndPoint_ax1;
//		- dwEndPoint_ax2;
//		- wCommand;					; IPO_L2	
// Line Interplation( 3 axes )  
//		- dwEndPoint_ax1;
//		- dwEndPoint_ax2;
//		- dwEndPoint_ax3;
//		- wCommand;					; IPO_L3	
// Arc  Interplation( only 2 axes )  
//		- dwEndPoint_ax1;			; Arc end point of axis 1
//		- dwEndPoint_ax2;			; Arc end point of axis 2
//		- dwCenPoint_ax1;			; Arc center point of axis 1
//		- dwCenPoint_ax1;			; Arc center point of axis 2	
//		- wCommand;					; IPO_CW,IPO_CCW		
typedef struct _MotMoveBuffer
{
  DWORD			dwEndPoint_ax1;		// End position for 1'st axis
  DWORD			dwEndPoint_ax2;		// End position for 2'nd axis
  DWORD			dwEndPoint_ax3;		// End position for 3'rd axis
  DWORD			dwCenPoint_ax1;		// Center position for 1'st axis	
  DWORD			dwCenPoint_ax2;		// Center position for 2'rd axis
  DWORD			dwPointNum;			// Serial number for current data

  WORD			wCommand;			// IPO_CW,IPO_CCW,IPO_L2,IPO_L3 			
  WORD			TempB;				// For internal using
  DWORD			TempA;				// For internal using

}	MotMoveBuffer, * LPMotMoveBuffer;


typedef struct _MotionDataStruct
{

	LPMotMoveBuffer		lpBufIDAddr;	// Buffer address			
	HGLOBAL				hBuf;			// Hanlde of Buffer 
	DWORD				dwAllPointNum;	// How many point of continue move ( get from P1240InitContiBuf)
	BOOLEAN				bPoint1Flag;	
	DWORD				dwEndPointNum;
  
}	MotDataStruct; 	


typedef struct _MotSpeedTable
{

	DWORD	dwSpeed;	// speed data
	DWORD	dwComp;		// comparator data
  
}	MotSpeedTable, * LPMotSpeedTable; 	

#endif //#ifndef _MCX314Info

//---------------------------------------------------
//   Return Code for PCI-1240
//---------------------------------------------------
#define FunctionNotSupport				0x0062
#define DeviceNotExist                  0x0063

// --------------------------------------------------
//   Used by PCI-1240 to read write SN
// --------------------------------------------------
#define RWSN								0x0312

// added by yongdong
typedef struct _VBoard_ID
{
	BYTE    byBoard_ID;
}   VBoard_ID, * LPVBoard_ID;

#endif //PCI1240_MIC3240_HEADER_PUBLIC

#ifndef ADV_PCI1240_HEADER
#define ADV_PCI1240_HEADER

#ifdef __cplusplus
extern "C"
{
#endif

FEXPORT LRESULT FTYPE P1240MotDevOpen(BYTE byBoard_ID);

FEXPORT LRESULT FTYPE P1240MotDevAvailable(DWORD *lpReturnBoardStatus);

FEXPORT LRESULT FTYPE P1240MotDevClose(BYTE byBoard_ID);

FEXPORT LRESULT FTYPE P1240MotAxisParaSet(BYTE byBoard_ID,
										  BYTE bySetAxis,
										  BYTE byTS,
										  DWORD dwSV,
										  DWORD dwDV,
										  DWORD dwMDV,
										  DWORD dwAC,
										  DWORD dwAK);

FEXPORT LRESULT FTYPE P1240MotChgDV(BYTE byBoard_ID,
									BYTE bySetAxis,
									DWORD dwSetDVValue);

FEXPORT LRESULT FTYPE P1240MotChgLineArcDV(BYTE byBoard_ID,
										   DWORD dwSetDVValue);

FEXPORT LRESULT FTYPE P1240MotCmove(BYTE byBoard_ID,
									BYTE byCMoveAxis,
									BYTE byAxisDirection);

FEXPORT LRESULT FTYPE P1240MotPtp(BYTE byBoard_ID,
								  BYTE byMoveAxis,
								  BYTE byRA,
								  LONG lPulseX,
								  LONG lPulseY,
								  LONG lPulseZ,
								  LONG lPulseU);

FEXPORT LRESULT FTYPE P1240MotLine(BYTE byBoard_ID,
								   BYTE byMoveAxis,
								   BYTE byRA,
								   LONG lPulseX,
								   LONG lPulseY,
								   LONG lPulseZ,
								   LONG lPulseU);

FEXPORT LRESULT FTYPE P1240MotArc(BYTE byBoard_ID,
								  BYTE byMoveAxis,
								  BYTE byRA,
								  BYTE byAxisDirection,
								  LONG lCenter1,
								  LONG lCenter2,
								  LONG lEnd1,
								  LONG lEnd2);

FEXPORT LRESULT FTYPE P1240MotArcTheta(BYTE byBoard_ID,
									   BYTE byMoveAxis,
									   BYTE byRA,
									   LONG lCenter1,
									   LONG lCenter2,
									   DOUBLE dMoveDeg);

FEXPORT LRESULT FTYPE P1240MotStop(BYTE byBoard_ID,
								   BYTE byStopAxis,
								   BYTE byStopMode);

FEXPORT LRESULT FTYPE P1240MotAxisBusy(BYTE byBoard_ID,
									   BYTE byCheckAxis);

FEXPORT LRESULT FTYPE P1240MotClrErr(BYTE byBoard_ID,
									 BYTE byClearAxis);

FEXPORT LRESULT FTYPE P1240MotRdReg(BYTE byBoard_ID,
									BYTE byReadAxis,
									WORD wCommandCode,
									DWORD *lpReturnValue);

FEXPORT LRESULT FTYPE P1240MotWrReg(BYTE byBoard_ID,
									BYTE byWriteAxis,
									WORD wCommandCode,
									DWORD dwWriteValue);

FEXPORT LRESULT FTYPE P1240MotSavePara(BYTE byBoard_ID,
									   BYTE bySaveAxis);

FEXPORT LRESULT FTYPE P1240MotEnableEvent(BYTE byBoard_ID,
										  BYTE bySettingAxis,
										  BYTE byX_AxisEvent,
										  BYTE byY_AxisEvent,
										  BYTE byZ_AxisEvent,
										  BYTE byU_AxisEvent);

FEXPORT LRESULT FTYPE P1240MotCheckEvent(BYTE  byBoard_ID,
										 DWORD *lpRetEventStatus,
										 DWORD dwMillisecond);

FEXPORT LRESULT FTYPE P1240MotRdMutiReg(BYTE  byBoard_ID,
										BYTE  byReadAxis,
										WORD  wCommandCode,
                                        DWORD *lpReturn_XAxisValue,
										DWORD *lpReturn_YAxisValue,
                                        DWORD *lpReturn_ZAxisValue,
										DWORD *lpReturn_UAxisValue);
///wang.long add for function name error 7-27-2006
FEXPORT LRESULT FTYPE P1240MotRdMultiReg(BYTE  byBoard_ID,
										BYTE  byReadAxis,
										WORD  wCommandCode,
                                        DWORD *lpReturn_XAxisValue,
										DWORD *lpReturn_YAxisValue,
                                        DWORD *lpReturn_ZAxisValue,
										DWORD *lpReturn_UAxisValue);

FEXPORT LRESULT FTYPE P1240MotWrMutiReg(BYTE  byBoard_ID,
										BYTE  byWriteAxis,
										WORD  wCommandCode,
                                        DWORD dwWrite_XAxisValue,
										DWORD dwWrite_YAxisValue,
                                        DWORD dwWrite_ZAxisValue,
										DWORD dwWrite_UAxisValue);
///wang.long add for function name error 7-27-2006
FEXPORT LRESULT FTYPE P1240MotWrMultiReg(BYTE  byBoard_ID,
										BYTE  byWriteAxis,
										WORD  wCommandCode,
                                        DWORD dwWrite_XAxisValue,
										DWORD dwWrite_YAxisValue,
                                        DWORD dwWrite_ZAxisValue,
										DWORD dwWrite_UAxisValue);

FEXPORT LRESULT FTYPE P1240MotHome(BYTE byBoard_ID,
								   BYTE byHomeAxis);

FEXPORT LRESULT FTYPE P1240MotHomeStatus(BYTE byBoard_ID,
										 BYTE byHomeAxis,
										 DWORD *lpReturnValue);

FEXPORT LRESULT FTYPE P1240MotDI(BYTE byBoard_ID,
								 BYTE byReadDIAxis,
								 BYTE *lpReturnValue);

FEXPORT LRESULT FTYPE P1240MotDO(BYTE byBoard_ID,
								 BYTE byWriteDOAxis,
								 BYTE byWriteValue);

FEXPORT LRESULT FTYPE P1240MotExtMode(BYTE byBoard_ID,
									  BYTE byAssignmentAxis,
									  BYTE byExternalMode,
									  LONG lPulseNum);

FEXPORT LRESULT FTYPE P1240MotReset(BYTE byBoard_ID);

FEXPORT LRESULT FTYPE P1240InitialContiBuf(BYTE byBufID, 
										   DWORD dwAllPointNum);

FEXPORT LRESULT FTYPE P1240FreeContiBuf(BYTE byBufID);

FEXPORT LRESULT FTYPE P1240SetContiData(BYTE				byBufID,
										LPMotMoveBuffer		lpPathData,
										DWORD				dwPointNum);

FEXPORT LRESULT FTYPE P1240StartContiDrive(BYTE		byBoard_ID,
										   BYTE		byMoveAxis,
										   BYTE		byBufID);

FEXPORT LRESULT FTYPE P1240GetCurContiNum(BYTE	byBoard_ID,
										  DWORD *lpReturnValue);

// Deng Feng add function: change position on fly
FEXPORT LRESULT FTYPE P1240ChgPosOnFly(BYTE	byBoard_ID,
                                 BYTE byMoveAxis,
                                 BYTE byRA,
                                 LONG lPulseX,
                                 LONG lPulseY,
                                 LONG lPulseZ,
								         LONG lPulseU );

/********************************************************************
/* Comparator Function
/********************************************************************/

FEXPORT LRESULT FTYPE P1240BuildCompTable(BYTE		byBoard_ID,
										   BYTE		byMoveAxis,
										   DWORD	*dwTableArray,
										   DWORD	dwAllPointNum	);

FEXPORT LRESULT FTYPE P1240BuildSpeedTable(BYTE				byBoard_ID,
										   BYTE				byMoveAxis,
										   MotSpeedTable	*SpeedTable,
										   DWORD			dwAllPointNum	);
/********************************************************************
/* Directly access the register Functions
/********************************************************************/

FEXPORT LRESULT FTYPE P1240SetCompPLimit ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 
								 LONG lWriteValue );

FEXPORT LRESULT FTYPE P1240SetCompNLimit ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 
					      	 LONG lWriteValue );

FEXPORT LRESULT FTYPE P1240EnableCompPLimit ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 
					      	 USHORT Enable );

FEXPORT LRESULT FTYPE P1240EnableCompNLimit ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 
					      	 USHORT Enable );

FEXPORT LRESULT FTYPE P1240SetPLimitLogic ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 
					      	 USHORT Value );

FEXPORT LRESULT FTYPE P1240SetNLimitLogic ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 
					      	 USHORT Value );

FEXPORT LRESULT FTYPE P1240SetCompareObject ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 
					      	 USHORT Value );

FEXPORT LRESULT FTYPE P1240SetPulseMode ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 
					      	 USHORT Value );

FEXPORT LRESULT FTYPE P1240SetPulseLogic ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 
					      	 USHORT Value );

FEXPORT LRESULT FTYPE P1240SetPulseDirLogic ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 
					      	 USHORT Value );

FEXPORT LRESULT FTYPE P1240SetEncoderMultiple ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 
					      	 USHORT Value );

FEXPORT LRESULT FTYPE P1240SetServoAlarm ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 
								 USHORT Enable,
					      	 USHORT Value );

FEXPORT LRESULT FTYPE P1240SetInPosition ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 
								 USHORT Enable,
					      	 USHORT Value );

FEXPORT LRESULT FTYPE P1240SetHomeLogic ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 								 
					      	 USHORT Value );

FEXPORT LRESULT FTYPE P1240SetZLogic ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 								 
					      	 USHORT Value );

FEXPORT LRESULT FTYPE P1240SetOutput ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 								 
					      	 USHORT Value );

FEXPORT LRESULT FTYPE P1240SetOutputType ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis, 								 
					      	 USHORT Enable );

FEXPORT LRESULT FTYPE P1240SetInputLogic ( 
	                      BYTE byBoard_ID, 
						       BYTE bySetAxis,
								 USHORT D4Value,
								 USHORT D6Value );

FEXPORT LRESULT FTYPE P1240GetError (
								 BYTE byBoard_ID, 
						       BYTE byGetAxis,
								 USHORT * lpValue	);

FEXPORT LRESULT FTYPE P1240GetDriverState (
								 BYTE byBoard_ID, 
						       BYTE byGetAxis,
								 USHORT * lpValue	);

FEXPORT LRESULT FTYPE P1240GetMotionState (
								 BYTE byBoard_ID, 
						       BYTE byGetAxis,
								 USHORT *lpValue	);

FEXPORT LRESULT FTYPE P1240GetMotionInput (
								 BYTE byBoard_ID, 
						       BYTE byGetAxis,
								 USHORT *lpValue	);

FEXPORT LRESULT FTYPE P1240GetCompareState (
								 BYTE byBoard_ID, 
						       BYTE byGetAxis,
								 USHORT *lpValue	);

FEXPORT LRESULT FTYPE P1240GetInput (
								 BYTE byBoard_ID, 
						       BYTE byGetAxis,
								 USHORT *lpValue );

// motion functions
FEXPORT LRESULT FTYPE P1240MoveAbs(
						       BYTE byBoard_ID,
								 BYTE byMoveAxis,								 
								 LONG lPulseNumber );

FEXPORT LRESULT FTYPE P1240MoveIns(
						       BYTE byBoard_ID,
								 BYTE byMoveAxis,								 
								 LONG lPulseNumber );

FEXPORT LRESULT FTYPE P1240MoveCircle(
							    BYTE byBoard_ID,
								 BYTE byMoveAxis,
								 BYTE byAxisDirection,								 
								 LONG lCenter1,
								 LONG lCenter2 );

FEXPORT LRESULT FTYPE P1240SetStartSpeed(
								 BYTE byBoard_ID,
								 BYTE bySetAxis,
								 DWORD lSpeedValue );

FEXPORT LRESULT FTYPE P1240SetDrivingSpeed(
								 BYTE byBoard_ID,
								 BYTE bySetAxis,
								 DWORD lSpeedValue );

FEXPORT LRESULT FTYPE P1240SetAcceleration(
								 BYTE byBoard_ID,
								 BYTE bySetAxis,
								 DWORD accel );

FEXPORT LRESULT FTYPE P1240SetDeceleration(
								 BYTE byBoard_ID,
								 BYTE bySetAxis,
								 DWORD decel,
                         LONG lRetrieve );    

FEXPORT LRESULT FTYPE P1240SetJerk(
								 BYTE byBoard_ID,
								 BYTE bySetAxis,
								 DWORD lJerk );

FEXPORT LRESULT FTYPE P1240SetRange(
								 BYTE byBoard_ID,
								 BYTE bySetAxis,
								 DWORD lRange );


FEXPORT LRESULT FTYPE P1240GetSpeed (
								 BYTE byBoard_ID, 
						       BYTE byGetAxis,
								 DWORD *lpValue );

FEXPORT LRESULT FTYPE P1240GetAcel (
								 BYTE byBoard_ID, 
						       BYTE byGetAxis,
								 DWORD *lpValue );

FEXPORT LRESULT FTYPE P1240GetPracticalRegister (
								 BYTE byBoard_ID, 
						       BYTE byGetAxis,
								 LONG *lpValue );

FEXPORT LRESULT FTYPE P1240GetTheorecticalRegister (
								 BYTE byBoard_ID, 
						       BYTE byGetAxis,
								 LONG *lpValue );

FEXPORT LRESULT FTYPE P1240SetPracticalRegister(
								 BYTE byBoard_ID,
								 BYTE bySetAxis,
								 LONG lPosition );

FEXPORT LRESULT FTYPE P1240SetTheorecticalRegister(
								 BYTE byBoard_ID,
								 BYTE bySetAxis,
								 LONG lPosition );

/*
// IPO
FEXPORT LRESULT FTYPE P1240MoveLineContinuous(
								 BYTE byBoard_ID,
								 BYTE byMoveAxis,
								 LONG lPosition1,
								 LONG lPosition2,
                         LONG lPosition3 );

FEXPORT LRESULT FTYPE P1240MoveArcContinuous(
								 BYTE byBoard_ID,
								 BYTE byMoveAxis,
								 BYTE byAxisDirection,
								 LONG lCenter1,
								 LONG lCenter2,
								 LONG lEnd1,
								 LONG lEnd2 );
*/

FEXPORT BOOL FTYPE P1240_OutpWord (
                      BYTE byBoard_ID,
                      unsigned short nPort,
                      unsigned short wWord );

FEXPORT BOOL FTYPE P1240_InpWord(
                      BYTE byBoard_ID,
                      unsigned short nPort,
                      unsigned short* ptWord );

// **** THE FOLLOWING DAQ FUNCTIONS DO NOT SEEM TO BE INCLUDED IN THE CURRENT .dll FILE ****
//                     Commented out by Chris Johnson September 2012

////The following DIO function are supported only on PEC3240 // added, 2008.10 
//FEXPORT LRESULT FTYPE P1240GetCPLDVersion(
//                      BYTE byBoard_ID,
//                      DWORD* ptdwCPLDVer );
//
//FEXPORT LRESULT FTYPE P1240DaqDiGetByte(
//                      BYTE byBoard_ID,
//                      unsigned short nPort,
//                      BYTE* ptbyDIData );
//
//FEXPORT LRESULT FTYPE P1240DaqDiGetBit(
//                      BYTE byBoard_ID,
//                      unsigned short DiChannel,
//                      BYTE* BitData );
//
//FEXPORT LRESULT FTYPE P1240DaqDoSetByte(
//                      BYTE byBoard_ID,
//                      unsigned short nPort,
//                     BYTE byDOData );
//
//FEXPORT LRESULT FTYPE P1240DaqDoSetBit(
//                      BYTE byBoard_ID,
//                      unsigned short DoChannel,
//                      BYTE ptbyDoData );
//
//FEXPORT LRESULT FTYPE P1240DaqDoGetByte(
//                      BYTE byBoard_ID,
//                      unsigned short nPort,
//                      BYTE* BitData );
//
//FEXPORT LRESULT FTYPE P1240DaqDoGetBit(
//                      BYTE byBoard_ID,
//                      unsigned short DoChannel,
//                      BYTE* BitData );
//

// shi.wei added, 2-18-2005.
FEXPORT LRESULT FTYPE P1240ReadEEPROM(
	BYTE byBoard_ID, 
	BYTE byEEPROMAddress, 
	unsigned short *pusReadValue );

FEXPORT LRESULT FTYPE P1240WriteEEPROM(
	BYTE byBoard_ID, 
	BYTE byEEPROMAddress, 
	unsigned short usWriteValue );
// shi.wei added end, 2-18-2005.

#ifdef __cplusplus
}
#endif

#endif //ADV_PCI1240_HEADER
