%% MACD
load('if000_m1');
Price = bardata(:,6);
FastLength = 12;
SlowLength = 26;
MACDLength = 9;

times = 1e2;
for i =1:times
    disp(i);
    [ Diff1 ] = MACD( Price,FastLength,SlowLength,MACDLength );
    [ Diff2 ] = trainMACD( Price,FastLength,SlowLength,MACDLength );
end

