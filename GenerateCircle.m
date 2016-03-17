 TrueTrace1 = GenerateTrace( [2200 100 0 5076 0 0 0 0 0;4924 0 0 7800 -100 0 0 0 0]', 0, 1, 17, [1 2]);
 TrueTrace2 = GenerateTrace( [TrueTrace1{1}.Data(:,17),TrueTrace1{2}.Data(:,17)], 17, 1, 16,[-0.098 0.098], [1 2],[0 0 0;0 0 0]',1);
 TrueTrace3 = GenerateTrace( [TrueTrace2{1}.Data(:,16),TrueTrace2{2}.Data(:,16)], 33, 1, 17, [1 2]); 
 TrueTrace{1}.Data =[TrueTrace1{1}.Data TrueTrace2{1}.Data TrueTrace3{1}.Data];
 TrueTrace{1}.Time =[TrueTrace1{1}.Time TrueTrace2{1}.Time TrueTrace3{1}.Time];
 TrueTrace{1}.ID =[TrueTrace1{1}.ID TrueTrace2{1}.ID TrueTrace3{1}.ID];
 
 TrueTrace{2}.Data =[TrueTrace1{2}.Data TrueTrace2{2}.Data TrueTrace3{2}.Data];
 TrueTrace{2}.Time =[TrueTrace1{2}.Time TrueTrace2{2}.Time TrueTrace3{2}.Time];
 TrueTrace{2}.ID =[TrueTrace1{2}.ID TrueTrace2{2}.ID TrueTrace3{2}.ID];
 
 hold on
 plot(TrueTrace{2}.Data(1,:),TrueTrace{2}.Data(4,:));
 plot(TrueTrace{1}.Data(1,:),TrueTrace{1}.Data(4,:));