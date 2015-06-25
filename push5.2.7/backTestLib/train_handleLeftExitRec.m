function [ completeEntryRecord,completeExitRecord ] = train_handleLeftExitRec( entryRecord,exitRecord,repairedRec )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

entryLength = size(entryRecord,1);
exitLength = size(exitRecord,1);
if  entryLength == exitLength
    completeEntryRecord = entryRecord;
    completeExitRecord = exitRecord;
else
    difLength = entryLength - exitLength;
    begLength = exitLength + 1;
    status = entryRecord(begLength:entryLength,1) * (-2);
    lots = entryRecord(begLength:entryLength,5);
    currents = entryRecord(begLength:entryLength,5) .* entryRecord(begLength:entryLength,1);
    repairedRec = repmat(repairedRec,difLength,1);
    completeEntryRecord = entryRecord;
    completeExitRecord = exitRecord;
    completeExitRecord(begLength:entryLength,:) = [status,repairedRec,lots,currents];
    %warningMsg = ['There are ',num2str(difLength),' record not close!'];
    %warning(warningMsg);
end

end

