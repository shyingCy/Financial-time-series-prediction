% Demo f黵 den Bereich Financial ZigZag Kurve erstellen aus
% Kurswerten von yahoo.com.
% 18. Oktober 2005
% marthiens@ifum.uni-hannover.de

clear all
close all

% 'MM/DD/YY'
D1 = '01/01/00'
D2 = '10/17/05'

% yahoo max. 200 Kurse von D2 r點kwirkend nach D1 abfragbar

% Spalte    Funktion
% 1         Date
% 2         Open
% 3         High
% 4         Low
% 5         Close
% 6         Volume
% 7         Close     
[ODBCName,user,pwd,dbName] = loadDBConfig();
conna = mysql('open','localhost',user,pwd);
mysql(['use ',dbName]);
[Date,Time,Open,High,Low,Close] = mysql('select Date,Time,Open,High,Low,Close from if888_d1;');
% daxkurse=fetch(yahoo,{'VOW.DE'},D1,D2,'d');
% Volumen=daxkurse(end:-1:1,6); %成交量
% Kurs=daxkurse(end:-1:1,7);  %收盘价
% Dateset=daxkurse(end:-1:1,1); %日期
% Datestartstr=datestr(Dateset(1))
Kurs = Close;
Dateset = Date;
Datestartstr = datestr(Dateset(1));

% =============================================
% ============== ZigZag =======================
% =============================================

% Wann wird ein Richtungswechsel erkannt
prozent=3;

% richtung =  0 unbekannte Steigung des aktuellen Arms
% richtung =  1 positive Steigung des aktuellen Arms
% richtung = -1 negative Steigung des aktuellen Arms
richtung=0;

% In ZZ werden die Wendepunkte gespeichert. Der erste
% ZigZag-Punkt ist der erste verf黦bare Kurs.
ZZ=0;
ZZ(1,1)=Dateset(1);
ZZ(1,2)=Kurs(1);

% In SF werden die Zeitpunkte eines Richtungswechsels
% gesichert und angezeigt. Wichtig, da der Zeitpunkt eines
% Richtungswechsel nicht mit dem Zeitpunkt der Entscheidung
% f黵 einen Richtungswechsel zusammenf鋖lt. ZigZag schaut
% nicht in die Zukunft sonderen in die Vergangenheit. 
SF=0;
SF(1,1)=richtung;

% Algorithmus
j=1;
for i=2:length(Kurs)

    % Aktuelle Kursabweichung in Prozent zum letzten
    % gefundenen h鯿hst bzw. niedrigsten ZigZag-Kurs
    relKurs  = (Kurs(i)-ZZ(j,2))/ZZ(j,2)*100;

    % Abschnitt wird nur einmal am Anfang durchlaufen.
    % Hier wird zun鋍hst nach der ersten m鰃lichen Richtung
    % gesucht. Dabei muss der aktuelle Kurs vom ersten Kurs
    % mindestens um Prozent abweichen, damit dann eine
    % Richtung entschieden werden kann. Dieser Zeitpunkt und
    % der akutelle Kurs bilden den zweiten Punkt der
    % ZigZag-Kurve
    if (abs(relKurs)>=prozent) & (richtung==0)
        j=j+1;
        ZZ(j,1)=Dateset(i);
        ZZ(j,2)=Kurs(i);
        richtung=sign(relKurs);
    end

    % Wenn der Kurs weiter steigt speichere dies in den
    % aktuellen ZigZag-Punkt
    if (Kurs(i)>=ZZ(j,2))   & (richtung==1)
        ZZ(j,1)=Dateset(i);
        ZZ(j,2)=Kurs(i);
    end
        
    % Wenn der akutelle Kurs zum letzten H鯿hstwert von ZZ
    % unter prozent liegt und die Richtigung positiv ist,
    % muss jetzt ein Richtungwechsel stattfinden. Der Kurs
    % f鋖lt demnach tendenziell.
    % Dazu wird ein neuer ZigZag-Punkt mit dem aktuellen
    % Kurs generiert und die Richtung ge鋘dert.
    if (relKurs < -prozent) & (richtung==1)
        richtung=-1;
        j=j+1;
        ZZ(j,1)=Dateset(i);
        ZZ(j,2)=Kurs(i);
    end

    % Wenn der Kurs weiter f鋖lt speichere dies in den
    % aktuellen ZigZag-Punkt.
    if (Kurs(i)<ZZ(j,2))    & (richtung==-1)
        ZZ(j,1)=Dateset(i);
        ZZ(j,2)=Kurs(i);
    end
    
    % Wenn der akutelle Kurs zum letzten Tiefstwert von ZZ
    % unter prozent liegt und die Richtigung positiv ist,
    % muss jetzt ein Richtungwechsel stattfinden. Der Kurs
    % steigt demnach tendenziell.
    % Dazu wird ein neuer ZigZag-Punkt mit dem aktuellen
    % Kurs generiert und die Richtung ge鋘dert.
    if (relKurs >= prozent) & (richtung==-1)
        richtung=1;
        j=j+1;
        ZZ(j,1)=Dateset(i);
        ZZ(j,2)=Kurs(i);
    end

    % Wenn sich der relKurs innerhalb von +-prozent bewegt,
    % und kein neuer H鯿hst- bzw. Tiefstwert gefunden wurde,
    % tue nichts und vergleiche mit dem n鋍hsten Kurs.
    
    % Richtung zu jedem Kurstag
    SF(i,1)=richtung;
end

% Letzter Kurs beendet auch den ZigZag-Kurs. Egal ob
% positive oder negative Richtung. Die Richtung kann sich
% erst durch zuk黱ftige Kurse 鋘dern.
j=j+1;
ZZ(j,1)=Dateset(i);
ZZ(j,2)=Kurs(i);
%%
% Anzeigen
figure
hold on

%plot(Dateset,Kurs, 'linewidth',3,'color','k')
axis([Dateset(1) Dateset(end) min(Kurs) max(Kurs)]);
dateaxis('x',2,Datestartstr)
avg1= 5;        % 3 Tage
avg2= 1000;       % 15 Tage

%[Avg1set,Avg2set]=movavg(Kurs, avg1, avg2, 1);
%plot(Dateset,Avg1set,'linestyle','--', 'linewidth',2,'color','g')
%plot(Dateset,Avg2set,'linestyle','--', 'linewidth',2,'color','c')

plot(ZZ(:,1),ZZ(:,2)','linestyle','--', 'linewidth',3,'color','r')
%DHLKurs=max(Kurs)-min(Kurs);
%plot(Dateset,(SF+1)/2*DHLKurs*0.9+min(Kurs)+DHLKurs*0.05,'linestyle','--', 'linewidth',1,'color','b')
