using Toybox.WatchUi as Ui;

class EnergyExpenditureFieldView extends Ui.SimpleDataField {
		
	hidden var mLastLapTimerTime = 0.0;
	hidden var mLastLapCalories  = 0.0;
	
	hidden var mEEField 		= null;
	hidden var mAverageEEField  = null;
	hidden var mLapEEField 		= null;
	
    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Energy Expenditure";
        
        mEEField 		 = createField("energy_expenditure", 			 0, FitContributor.DATA_TYPE_UINT16, { :mesgType=>FitContributor.MESG_TYPE_RECORD,  :units=>"kcal/h" });
        mAverageEEField  = createField("average_energy_expenditure", 	 1, FitContributor.DATA_TYPE_UINT16, { :mesgType=>FitContributor.MESG_TYPE_SESSION, :units=>"kcal/h" });
        mLapEEField 	 = createField("lap_average_energy_expenditure", 2, FitContributor.DATA_TYPE_UINT16, { :mesgType=>FitContributor.MESG_TYPE_LAP, 	:units=>"kcal/h" });
    }
    

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        var mEnergyExpenditure = 0;
        if (info has :energyExpenditure && info.energyExpenditure != null) {
        	//! Convert from kcal/min to kcal/h
        	mEnergyExpenditure = (info.energyExpenditure * 60).toNumber();
        }
        mEEField.setData(mEnergyExpenditure);
        
        var mAverageEE = 0;
        if (info has :calories && info has :timerTime && info.timerTime != null && info.timerTime > 0 && info.calories != null) {
        	//! Calculate average from calories/time
        	mAverageEE = ( info.calories / (info.timerTime / 3600000.0) ).toNumber();
        }
        mAverageEEField.setData(mAverageEE);
        
        var mLapEE = 0;
        if (info has :calories && info has :timerTime && info.timerTime != null && info.timerTime > mLastLapTimerTime && info.calories != null) {
        	//! Calculate lap average from calories/time since last lap marker(s)
        	mLapEE = ( (info.calories - mLastLapCalories) / ( (info.timerTime - mLastLapTimerTime) / 3600000.0) ).toNumber();
        }
        mLapEEField.setData(mLapEE);
        
        return mEnergyExpenditure;
    }
    
    
    //! Store last lap quantities and set lap markers
    function onTimerLap() {
    	var info = Activity.getActivityInfo();

    	mLastLapTimerTime	= (info has :timerTime && info.timerTime != null) ? info.timerTime : 0.0;
    	mLastLapCalories	= (info has :calories  && info.calories != null)  ? info.calories  : 0.0;    	
    }


    //! Current activity is ended
    function onTimerReset() {
		mLastLapTimerTime	= 0.0;
		mLastLapCalories 	= 0.0;
    }

}