fileList = dir('sub*.csv');

for file = fileList'
    disp(file.name)
    clearvars -except fileList file
    format short
    rand('state', sum(100*clock));

    %this sets up the path of matlabs to point to the models and other
    %necesssary programs

    addpath(genpath('../../input_output/'));
    addpath(genpath('../'));

    %set up the data vectors
    theData = csvread(file.name, 1, 0);

    % sub     block   balloon pump    explode or not
    % 1       1       1       40      0
    % 1       1       2       62      0
    % .
    % .
    % .
    % 1       1       30       8      1
    % 2       1       1       34      0
    % .
    % .
    % .
    % numSub  1       30      28      1

    %%%adjust these column vectors according to your data file.
    subject = theData(:,1);
    block = theData(:,2);
    trial = theData(:,3);
    puffs = theData(:,4);
    explosion = theData(:,5);

    numSubjects = 1;

    %----------what model do you want ------------------
    whichModel = 1;
    if (whichModel == 1)
        modelName = 'PES_';
        modelHandle = @likelihood_pesc;  
    end;

    %--------------------Basic parameters needed to run the models...
    numPars = 4;%numPars is no. parameters in the models...used to set up starting values

    pcheckerCrit = 3000;  %the abs(logLikelihood) criterion needed for a set of parameters to be fed %into fminsearch (see parchecker)

    maxPump = 128; %how many total pumps were allowed in the balloon

    rew = 1; %the size of reward received on each pump.

    unbounded = 1;  %if need to send unbounded (reals) parameters into the models (fminsearch) requires %this but not for example fmincon

    know = 0;

    %set up options for fminsearch...simulations has shown this is the best set
    %up for the models when using format short (see above)
    options = optimset('MaxFunEvals',500.*numPars, 'MaxIter', 200.*numPars, 'LargeScale','off', 'TolFun', 1.0000e-004, 'TolX',1.0000e-004 );
    %'Display', 'iter',

    theSize = 3.*ones(1,numPars); %a vector used to select starting parameters later...see below

    maxIterations = 3^numPars;%min(3^numPars, 50);%the number of starting values used

    theSummary = []; %the matrix that will hold the output from minsearch...use a concatnation %funciton to build

    %specifies the session. Since BART is usually run 3 x 30 we can set session
    %= 0, 1,2,3 to return the specific session. 0 returns the entire 90
    %rounds...since models are based on cumulative experience should estimate
    %the models in that way. What you learn in session 1 transfers to session
    %2.
    theSession = 0;

    %-----------------------fit the models at subject level------

    for theSub = 1:numSubjects;

        t0 = clock;% an initial clock reading that is used to stops the parameter search % if it takes to dang long (3 hours). Probably an old problem...but a% worthwile check

        [blockPuffs, blockExplosion] = getSubjectDataBART(theSub, theSession, subject, block, puffs, explosion); %get the subject data

        if (~isempty(blockPuffs)) %run the routine if the subject exists

            %randomArray = rand(1,3.^numPars);%generate a random vector for selecting parameters

            %[theRand randIndex] = sort(randomArray);%sort to get a random index to select  particular sectors of%parameters...do this so that sectors are not resampled for start

            %the initial vectors holding output from optimization
            fvalMemory = [];
            fval = 0;
            xmemory = [];
            exitflagmemory = [];
            loop = 1;
            loopCounter = 1;
            rerun = 0;
            timedout = 0;

            while (loop <= maxIterations)%run routine up to maxiterations (that means the number of start values used is no bigger than maxIterations
                %return the sector for each parameter that will be used for a
                %start value...this is confusing and I never can explain it...I
                %just know it works
                [x1, x2, x3, x4] = ind2sub(theSize, loop);%randIndex(loop)

                %set up the start values for each parameter. Parsectors is a
                %program that draws a random value for a parameters for a
                %designated parameter. So for example for W 3 different start
                %values will be chosen first is between 0 and .33. The second
                %between .33 and .66 and the third between .66 and .99.
                if(whichModel == 1)
                    beta = ParSectors(3, [.33, .33, .33], [0, .33, .66]);
                    gamma1= ParSectors(3, [.45, .45, .45], [0, .45, .90]);            
                    a0 = ParSectors(3, [333, 333, 333], [0, 333, 666]);
                    b0 = ParSectors(3, [333, 333, 333], [0,333, 666]);

                    xparin = [parameter_bounder(beta(x1),0,0,10), parameter_bounder(gamma1(x2),0,0,1.35),parameter_bounder(a0(x3),0,0,1000), parameter_bounder(b0(x4),0,0,1000)];
                end;

                %send the parameters into neldermead_checker which does 3
                %things:1.) checks the start values to see if they give a abs
                %(loglikelihood) beloww pcheckerCrit. 2.) if not then tries to
                %shake them to get values that are in the same general area
                %that do meet the criterion 3.) if below criterion then fed
                %into fminsearch.
                [xout, fout, theflag] = neldermead_checker( modelHandle, xparin, pcheckerCrit, options, rew, maxPump, unbounded,know, blockPuffs, blockExplosion );

                %build a vector holding minimized abs(likelihood) value (fout)
                %and minimized parameters (xout).
                if (theflag == 1 && ~isempty(xout))

                    if (whichModel == 1)
                        xparout = [parameter_bounder(xout(1),1,0,10), parameter_bounder(xout(2),1,0,1.35), parameter_bounder(xout(3),1,0,1000), parameter_bounder(xout(4),1,0,1000)]; 
                    end;

                    fvalMemory = [fvalMemory; fout];
                    xmemory = [xmemory; xparout];
                    exitflagmemory = [exitflagmemory; theflag];
                else
                    fvalMemory = [fvalMemory; []];
                    xmemory = [xmemory; []];
                    exitflagmemory = [exitflagmemory; []];
                end;

                if (etime(clock,t0) > 10800)
                    %if more than 3 hours per subject...must stop
                    timedout = 1;
                    break;
                end;

                loop = loop +1;
            end;

            %after while loop is over then find the min of the minimums
            [minxout, minfout, minflag] = minFinder(xmemory, fvalMemory, exitflagmemory);
            [rmem, cmem] = size(fvalMemory);

            %the summary ad hoc measures...put this at the end of the summary
            [ adjBART, medBART, stdBART, propPop ] = bartscore( blockPuffs, blockExplosion );

            %the baseline model...keep in the summary...for comparisons
            %purposes.
            [LL_stop, q_stop, LL_all, q_all] = baseLineBN(blockPuffs, blockExplosion);

            %add the output to the summary
            if(~isempty(fvalMemory))
                [pout, varpout] = betastat(minxout(3), minxout(4));
                theSummary = [theSummary; theSub, minxout,pout, varpout -minfout, loop, rmem, minflag, timedout, LL_all, q_all, adjBART, medBART, stdBART, propPop];

                %output:
                %sub    beta	gamma	a0	b0  phat    var(phat)	loglike
                %numloops	numsuccess	foundmin	timedout
                %log_like_baseline	prob_pump	adjBART	medianBART  stdevPumps
                %proppump
            end;

            %write the data file in 2 formats: a .txt file that is used for
            %excel and sas or spss.
            %a .mat file used for matlab stuff.
            %all files have a date in the name to help reduce possible
            %overwrites.
            theDate = date;

            theFile = '../../input_output/modelEstimates/BART2_'; fileType = '.txt'; fpath = [theFile modelName theDate file.name(1:end-4) fileType];

            dlmwrite(fpath,theSummary,'\t'); 

            theMatFile = '../../input_output/modelEstimates/BART2_'; fullMatName = [theMatFile modelName theDate];

            save(fullMatName);
        end;

    end;
end