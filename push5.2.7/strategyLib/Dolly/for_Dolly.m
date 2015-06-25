function [entryRecord,exitRecord,my_currentcontracts,obj,vararg] = for_Dolly( strategy,bardata,pro_information,ConOpenTimes,isMoveOn,trainBeg,trainEnd,strategyArg,varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

pro = getTestPro(strategy);
trainData = bardata(trainBeg:trainEnd,:);
count = 1;
vararg = {};
my_currentcontracts = varargin{2};
entryRecord = [];
exitRecord = [];
Close = bardata(:,6);
curDate=bardata(:,1)+bardata(:,2);
%-----------------------------------------%
fast1=3;
fast2=5;
fast3=8;
fast4=10;
fast5=12;
fast6=15;
slow1=30;
slow2=35;
slow3=40;
slow4=45;
slow5=50;
slow6=60;
fastlength=12;
slowlength=26;
MACDlength=9;

tempD = load([pro,'_m1']);
close_m1=tempD.bardata(:,6);
Date_m1=tempD.bardata(:,1)+tempD.bardata(:,2);
tempD = load([pro,'_m5']);
close_m5=tempD.bardata(:,6);
Date_m5=tempD.bardata(:,1)+tempD.bardata(:,2);
tempD = load([pro,'_m15']);
close_m15=tempD.bardata(:,6);
Date_m15=tempD.bardata(:,1)+tempD.bardata(:,2);
tempD = load([pro,'_m30']);
close_m30=tempD.bardata(:,6);
Date_m30=tempD.bardata(:,1)+tempD.bardata(:,2);
tempD = load([pro,'_h1']);
close_h1=tempD.bardata(:,6);
Date_h1=tempD.bardata(:,1)+tempD.bardata(:,2);

diff_m1=MACD(close_m1,fastlength,slowlength,MACDlength);
diff_m5=MACD(close_m5,fastlength,slowlength,MACDlength);
diff_m15=MACD(close_m15,fastlength,slowlength,MACDlength);
diff_m30=MACD(close_m30,fastlength,slowlength,MACDlength);
diff_h1=MACD(close_h1,fastlength,slowlength,MACDlength);

newdiff_m1=tran(curDate,Date_m1,diff_m1);
newdiff_m5=tran(curDate,Date_m5,diff_m5);
newdiff_m15=tran(curDate,Date_m15,diff_m15);
newdiff_m30=tran(curDate,Date_m30,diff_m30);
newdiff_h1=tran(curDate,Date_h1,diff_h1);
newDate_m1=tran(curDate,Date_m1,Date_m1);
newDate_m5=tran(curDate,Date_m5,Date_m5);
newDate_m15=tran(curDate,Date_m15,Date_m15);
newDate_m30=tran(curDate,Date_m30,Date_m30);
newDate_h1=tran(curDate,Date_h1,Date_h1);

FMACD1=EMA(Close,fast1);
FMACD2=EMA(Close,fast2);
FMACD3=EMA(Close,fast3);
FMACD4=EMA(Close,fast4);
FMACD5=EMA(Close,fast5);
FMACD6=EMA(Close,fast6);

SMACD1=EMA(Close,slow1);
SMACD2=EMA(Close,slow2);
SMACD3=EMA(Close,slow3);
SMACD4=EMA(Close,slow4);
SMACD5=EMA(Close,slow5);
SMACD6=EMA(Close,slow6);

for guppylength=strategyArg{1}
    if trainBeg > guppylength
        a = {FMACD1(trainBeg - guppylength:trainEnd),FMACD2(trainBeg - guppylength:trainEnd),FMACD3(trainBeg - guppylength:trainEnd),...
            FMACD4(trainBeg - guppylength:trainEnd),FMACD5(trainBeg - guppylength:trainEnd),FMACD6(trainBeg - guppylength:trainEnd),...
            SMACD1(trainBeg - guppylength:trainEnd),SMACD2(trainBeg - guppylength:trainEnd),SMACD3(trainBeg - guppylength:trainEnd),...
            SMACD4(trainBeg - guppylength:trainEnd),SMACD5(trainBeg - guppylength:trainEnd),SMACD6(trainBeg - guppylength:trainEnd)};
        b = {newdiff_m1(trainBeg - guppylength:trainEnd),newdiff_m5(trainBeg - guppylength:trainEnd),newdiff_m15(trainBeg - guppylength:trainEnd),...
            newdiff_m30(trainBeg - guppylength:trainEnd),newdiff_h1(trainBeg - guppylength:trainEnd)};
        c = {newDate_m1(trainBeg - guppylength:trainEnd),newDate_m5(trainBeg - guppylength:trainEnd),newDate_m15(trainBeg - guppylength:trainEnd),...
            newDate_m30(trainBeg - guppylength:trainEnd),newDate_h1(trainBeg - guppylength:trainEnd)};
        Data = bardata(trainBeg-guppylength:trainEnd,:);
    else
        a = {FMACD1(trainBeg:trainEnd),FMACD2(trainBeg:trainEnd),FMACD3(trainBeg:trainEnd),...
            FMACD4(trainBeg:trainEnd),FMACD5(trainBeg:trainEnd),FMACD6(trainBeg:trainEnd),...
            SMACD1(trainBeg:trainEnd),SMACD2(trainBeg:trainEnd),SMACD3(trainBeg:trainEnd),...
            SMACD4(trainBeg:trainEnd),SMACD5(trainBeg:trainEnd),SMACD6(trainBeg:trainEnd)};
        b = {newdiff_m1(trainBeg:trainEnd),newdiff_m5(trainBeg:trainEnd),newdiff_m15(trainBeg:trainEnd),...
            newdiff_m30(trainBeg:trainEnd),newdiff_h1(trainBeg:trainEnd)};
        c = {newDate_m1(trainBeg:trainEnd),newDate_m5(trainBeg:trainEnd),newDate_m15(trainBeg:trainEnd),...
            newDate_m30(trainBeg:trainEnd),newDate_h1(trainBeg:trainEnd)};
        Data = trainData(guppylength+1:trainEnd,:);;
    end
    for Diff=strategyArg{2}
        for K=strategyArg{3}
            [totalCon,FS] = Dollycondition(Data,guppylength,Diff,K,a,b,c);
            if trainBeg>guppylength
                con = totalCon(guppylength+1:guppylength+trainEnd-trainBeg+1);
                Fmax = FS{1}(guppylength+1:guppylength+trainEnd-trainBeg+1);
                Fmin = FS{2}(guppylength+1:guppylength+trainEnd-trainBeg+1);
                Smax = FS{3}(guppylength+1:guppylength+trainEnd-trainBeg+1);
                Smin = FS{4}(guppylength+1:guppylength+trainEnd-trainBeg+1);
                FS = {Fmax,Fmin,Smax,Smin};
            else
                con = totalCon;
            end
            [entryRecord,exitRecord] = train_Dolly(trainData,pro_information,con,FS,ConOpenTimes);
            [obj(count,:),entryRecord,exitRecord] = train_reportVar(trainData,entryRecord,exitRecord,0,pro_information,isMoveOn,varargin{:});
            count = count + 1;
        end
    end
end

varargout(1) = {obj};

end

