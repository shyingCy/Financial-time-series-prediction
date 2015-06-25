function [entryRecord,exitRecord,my_currentcontracts] = train_para(data,pro_information,chris,pink,ConOpenTimes)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%�������
%strategy:������Ϊ�ַ�
%dataΪ�������
%pro_informationΪ��Ʒ���
%ConOpenTimesΪ����ִ���
%���ϲ�������޸�
%k,nΪ���Բ���
%TrailingStart,TrailingStop,StopLossSet��ֹ���������Ҫֹ��������

%------����Ϊ�̶����������޸�--------%
%����
MinPoint = pro_information{3}; %��Ʒ��С�䶯��λ


%����
preciseV = 2e-7; %���ȱ�����������ֵ��ȵľ�������

%����
%K�߱���
Date = data(:,1);
Time = data(:,2);
Open = data(:,3);
High = data(:,4);
Low = data(:,5);
Close = data(:,6);
barLength = size(Date,1); %K������

%��������������Ҫ�ı���
entryRecord = []; %���ּ�¼
exitRecord = []; %ƽ�ּ�¼
my_currentcontracts = 0;  %�ֲ�����

%---------------------------------------%
%---------------------------------------%

%---------���±��������Ҫ�����޸�--------%
%���Ա���

MyEntryPrice = []; %���ּ۸񣬱����ǿ��־�ۣ�Ҳ�ɸ����Ҫ����Ϊĳ���볡�ļ۸�

HighestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���߼�
LowestAfterEntry=zeros(barLength,1); %���ֺ���ֵ���ͼ�
AvgEntryPrice = 0;

MarketPosition = 0;
BarsSinceEntry = -1; %�������һ�ο���K������-1��ʾû���֣����ڵ���0��ʾ�ڳֲ������
%---------------------------------------%
%---------------------------------------%

%�����ʼ���
SupClose = (Close - Close(1))*10;
%����
%ÿ�����
begin = 1;
work = 0;
times = 0;
for i = 1:barLength-1
    
    %-----�����������Ϊ��ֹ������ֹ�����ɾ��------%
    %�漰��ֹ��ı�����HighestAfterEntry��LowestAfterEntry��BarsSinceEntry��MyEntryPrice
    %     if i > 1
    %         HighestAfterEntry(i) = HighestAfterEntry(i-1);
    %         LowestAfterEntry(i) = LowestAfterEntry(i-1);
    %     end
    %     if MarketPosition~=0
    %         BarsSinceEntry = BarsSinceEntry+1;
    %     end
    %-----------------------------------------------%
    %-----------------------------------------------%
    
    %�������
    %����� ���⴦��
    if (i- begin < chris + 1)
    else
        if ((i-begin) == (chris + 1))
            %ǰһ��
            y1 = SupClose(begin:i-1);
            x = (1:i-begin);
            num = polyfit2(x,y1');
            %Ϊ��¼���������
            times  = times + 1;
            numSer(times,:) = num;
            a1 = num(1);
            b1 = num(2);
            %��ǰ��
            y2 = SupClose(begin:i);
            %       x = (begin:i);
            x=(1:i-begin+1);
            num = polyfit2(x,y2');
            %Ϊ��¼���������
            times  = times + 1;
            numSer(times,:) = num;
            a2 = num(1);
            b2 = num(2);
        end
        %a1Ϊǰһ��,a2Ϊ����,a0Ϊ�յ���ֵ�һ��
        if ((i-begin) > (chris + 1))%��bar��ĿС��chris֮ǰ,���������
            y2 = SupClose(begin:i);
            x=(1:i-begin+1);
            num = polyfit2(x,y2');
            %Ϊ��¼���������
            times  = times + 1;
            numSer(times,:) = num;
            a1 = a2;
            b1 = b2;
            a2 = num(1);
            b2 = num(2);%�˴��߼�����(?),��Ч������.10.13δ���%15.4.6Ŀ���ѽ��
        end
        if(i==work)%��֤�յ�
            if((a0*a2)>0)%���ƿ���,ȷ�Ϲյ�
                if(a2>0) %��������
                    [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_buy(entryRecord,exitRecord,my_currentcontracts,...
                        Date(i+1),Time(i+1),Open(i+1),1,ConOpenTimes); %����ֻ���޸�max(Open(i),smallswing(i))������Ǽ۸�
                    %isSucess�ǿ����Ƿ�ɹ��ı�־
                    if isSucess == 1
                        BarsSinceEntry = 0; %����ֹ���ɾ��
                        MyEntryPrice(1) = Open(i+1); %����ֹ���ɾ��
                        MarketPosition = 1; %��Ҫ�õ�MarketPosition�����ã�����Ҫ��ɾ��
                    end
                    %�������¼����
                else %�����Ƶ�
                    [entryRecord,exitRecord,my_currentcontracts,isSucess] = train_sellshort(entryRecord,exitRecord,my_currentcontracts,...
                        Date(i),Time(i),Open(i),1,ConOpenTimes);
                    if isSucess == 1
                        BarsSinceEntry = 0;
                        MyEntryPrice(1) = Open(i);
                        MarketPosition = -1;
                    end
                end
                begin=i;
            end
        else
            if(work>i);%�ڹյ��ѳ���,��δȷ���ڼ�,�����в���
            else%�յ���δ����
                %�жϹյ��Ƿ����
                %�����������۲�
                d1 = 2*a1*(i-begin+1) + b1;
                d2 = 2*a2*(i-begin+1) + b2;
                if(d1*d2<=0.001)%�յ���� �ص�����!
                    work = i + pink;
                    a0 = a2;
                    b0 = b2;%������ʱ��������߲���
                end
            end
        end
    end
end
    %---------------ֹ������---------------%
    %=====================================%
%     if BarsSinceEntry == 0
%         AvgEntryPrice = mean(MyEntryPrice);
%         HighestAfterEntry(i) = Close(i);
%         LowestAfterEntry(i) = Close(i);
%         if MarketPosition ~= 0
%             HighestAfterEntry(i) = max(HighestAfterEntry(i),AvgEntryPrice);
%             LowestAfterEntry(i) = min(LowestAfterEntry(i),AvgEntryPrice);
%         end
%     elseif BarsSinceEntry > 0
%         HighestAfterEntry(i) = max(HighestAfterEntry(i),High(i));
%         LowestAfterEntry(i) = min(LowestAfterEntry(i),Low(i));
%     end
%     
%     temp=AvgEntryPrice; %���ּ۸���
%     if MarketPosition==1 && BarsSinceEntry > 0
%         if HighestAfterEntry(i-1) > (temp+TrailingStart*MinPoint) || abs(HighestAfterEntry(i-1) - (temp+TrailingStart*MinPoint)) < preciseV
%             if (Low(i) < (HighestAfterEntry(i-1) - TrailingStop*MinPoint)) || abs(Low(i) - (HighestAfterEntry(i-1) - TrailingStop*MinPoint)) < preciseV
%                 MyExitPrice = HighestAfterEntry(i-1) - TrailingStop*MinPoint;
%                 if Open(i) < MyExitPrice
%                     MyExitPrice = Open(i);
%                 end
%                 [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
%                     Date(i),Time(i),MyExitPrice,1);
%                 MarketPosition = 0;
%                 BarsSinceEntry = 0;
%                 MyEntryPrice = []; %���ÿ��ּ۸�����
%             end
%         elseif Low(i) < (temp -StopLossSet*MinPoint) || abs(Low(i) - (temp -StopLossSet*MinPoint)) < preciseV
%             MyExitPrice = temp - StopLossSet*MinPoint;
%             if Open(i) < MyExitPrice
%                 MyExitPrice=Open(i);
%             end
%             [exitRecord,my_currentcontracts] = train_sell(exitRecord,my_currentcontracts,...
%                 Date(i),Time(i),MyExitPrice,1);
%             MarketPosition = 0;
%             BarsSinceEntry = 0;
%             MyEntryPrice = []; %���ÿ��ּ۸�����
%         end
%     elseif MarketPosition==-1 && BarsSinceEntry > 0
%         if LowestAfterEntry(i-1) < (temp - TrailingStart*MinPoint) || abs(LowestAfterEntry(i-1) - (temp - TrailingStart*MinPoint)) < preciseV
%             if (High(i) > (LowestAfterEntry(i-1) + TrailingStop*MinPoint)) || abs(High(i)-(LowestAfterEntry(i-1) + TrailingStop*MinPoint)) < preciseV %�����ʾ���ڻ����
%                 MyExitPrice = LowestAfterEntry(i-1) + TrailingStop*MinPoint;
%                 if Open(i) > MyExitPrice
%                     MyExitPrice = Open(i);
%                 end
%                 [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
%                     Date(i),Time(i),MyExitPrice,1);
%                 MarketPosition = 0;
%                 BarsSinceEntry = 0;
%                 MyEntryPrice = []; %���ÿ��ּ۸�����
%             end
%         elseif High(i) > (temp+StopLossSet*MinPoint) || abs(High(i) - (temp+StopLossSet*MinPoint)) < preciseV
%             MyExitPrice = temp+StopLossSet*MinPoint;
%             if Open(i) > MyExitPrice
%                 MyExitPrice=Open(i);
%             end
%             [exitRecord,my_currentcontracts] = train_buyToCover(exitRecord,my_currentcontracts,...
%                 Date(i),Time(i),MyExitPrice,1);
%             MarketPosition = 0;
%             BarsSinceEntry = 0;
%             MyEntryPrice = []; %���ÿ��ּ۸�����
%         end
%     end
% end

end


