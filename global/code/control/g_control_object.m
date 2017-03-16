classdef g_control_object < handle
    %%GANTRY A class to handle various aspects of interaction with the gantry
    %robot.
    % This primary reason for this class is so that we have a safe and
    % consistent procedure for the storage, access and use of states and
    % conversion factors pertaining to the gantry robot...
    %
    % For example...
    %   Lots of boring detail on the public methods...
    %
    % Note: I had to extend handle here in order for the destructor (delete
    % method) to be called.
    
    properties (GetAccess=public, SetAccess=private)
        alex_offset = [98 96 0]';
        limitmm;
    end
    
    %% private class properties
    properties (GetAccess=private, SetAccess=private)
        
        % ALL PROPERTIES ARE KEPT PRIVATE, EVEN THOSE WHICH MAY BE MODIFIED
        % AT RUNTIME INCLUDING CURRENT MOTOR DIRECTIONS.
        
        % GIVEN AN OBJECT obj WITH PROPERTY a, SUPPOSE THAT PROPERTY IS
        % READ-ONLY, THEN IF WE RUN obj.a = 10 THE PROPERTY WILL NOT BE
        % MODIFIED BUT A STRUCT obj WILL BE CREATED WITH A MEMBER a WHICH
        % EQUALS 10 - THIS 'GHOST' WILL REPLACE OUR OBJECT! THEREFORE ALL
        % ACCESS TO THIS CLASS WILL BE THROUGH METHODS
        
        ratio;
        
        simulate;
        
        % ratio from axis measured speed to pulses
        speedRatio;
        
        maxVel;
        
        maxAccel;
        
        limit;
        
        zone1;
        zone1_max_accel;
        zone2;
        
        origin_safe;
        limit_safe;
        
        debug; % debug mode on or off
        ticID; % timer ID
        vid = NaN; % video stream
        
        lastVel = [0;0;0];
        rundata;
        
        saveDir = ' ';
        frameCounter = 1;
        
        disableZ = 0;
        
        % private properties end
    end
    
    
    %% public methods
    methods(Access = public)
        
        % constructor
        
        % PERHAPS I WILL ALLOW THE PASSING OF SOME ARGUMENTS
        % FOR EXAMPLE, SUBJECT TO SOME SAFE MAXIMUMS I SET I CAN ALLOW THE
        % USER TO SET THEIR OWN MAXIMUM VELOCITIES AND SO ON?
        
        function g = g_control_object(debug, do_home_gantry, disableZ, acuity, maxV, maxA, showvidpreview, simulate)
            
            if nargin < 8 || isempty(simulate)
                g.simulate = false;
            else
                g.simulate = simulate;
            end
            if nargin < 7 || isempty(showvidpreview)
                showvidpreview = false;
            end
            if nargin < 6 || isempty(maxA)
                maxA = [20;20;20];
            end
            if nargin < 5 || isempty(maxV)
                maxV = [240;240;151];
            end
            if nargin < 4 || isempty(acuity)
                acuity = 1;
            end
            if nargin < 3 || isempty(disableZ)
                disableZ = false;
            end
            if nargin < 2 || isempty(do_home_gantry)
                do_home_gantry = true;
            end
            if nargin < 1 || isempty(debug)
                debug = false;
            end
            
            if g.simulate
                disp('RUNNING IN SIMULATION MODE')
            end
            
            disp(' ');disp('Preparing robot');disp(' ')
            if ~g.simulate
                g.openGantry();
                if do_home_gantry
                    g.home_gantry(disableZ);
                end
            end
            g.disableZ = disableZ;
            
            g.ticID = tic;
            g.debug = debug;
            % read properties in from some read-only file
            g.readIni();
            
            % get the conversion constant for speed measurement from the PCI
            % card
            if ~g.simulate
                if libisloaded('ADS1240')
                    p = libpointer('uint32Ptr',0);
                    e = calllib('ADS1240', 'P1240MotRdReg', 0, 4, 768, p);
                    if e
                        % SOME ERROR
                    end
                    R = double(get(p,'Value'));
                else
                    error('You may not create a Gantry object without first loading the ADS1240 PCI library')
                end
                g.speedRatio = 8000000 / R;
            end
            
            %             if (nargin ~= 4) && (nargin ~= 6)
            %                 error('Number of arguments to Gantry constructor should be either 4 or 6')
            %             end
            
            % AS WELL AS SETTING LIMITS FOR VELOCITIES AND ACCELERATIONS,
            % WHAT ABOUT ALSO SETTING THE LIMITS OF THE WORKSPACE?
            
            maxV = g.mm2pulses(maxV,'XYZ');
            maxA = g.mm2pulses(maxA,'XYZ');
            tempV = zeros(3,1);
            tempA = zeros(3,1);
            for t = 1:3
                % CHECK DIMENSIONS OF ARGUMENTS ARE BOTH CORRECT FIRST!
                
                % ALSO CONVERT FROM MM 2 PULSES - THE (AVERAGE) USER IS NOT
                % SUPPOSED TO HAVE TO WORRY ABOUT PULSES AT ALL
                
                if maxV(t) <= g.maxVel(t)
                    tempV(t) = maxV(t);
                else
                    disp(' '); disp('   Upper limits for velocities are:'); disp(' ')
                    disp([['     ';'     ';'     '] num2str(g.pulses2mm(g.maxVel,'XYZ'))]);
                    error('You may not set maximum velocities to over the above values')
                end
                
                if maxA(t) <= g.maxAccel(t)
                    tempA(t) = maxA(t);
                else
                    disp(' '); disp('   Upper limits for accelerations are:'); disp(' ')
                    disp([['     ';'     ';'     '] num2str(g.pulses2mm(g.maxAccel,'XYZ'))]);
                    error('You may not set maximum accelerations to over the above values')
                end
            end
            g.maxVel = tempV;
            g.maxAccel = tempA;
            
            
            g.origin_safe = [g.zone2
                g.zone2
                g.zone2];
            
            g.limit_safe = g.limit - g.origin_safe;
            
            %             disp(' ')
            %             disp('Gantry object is created with the parameters: '); disp(' ')
            %             disp('   Maximum operating velocities (mm/s): '); disp(' ')
            %             disp([['     ';'     ';'     '] num2str(g.pulses2mm(g.maxVel,'XYZ'))]); disp(' ')
            %             disp('   Maximum operating accelerations (mm/s/s): '); disp(' ')
            %             disp([['     ';'     ';'     '] num2str(g.pulses2mm(g.maxAccel,'XYZ'))]); disp(' ')
            
            if g.debug
                g.printFields()
            end
            
            % ALSO PRINT SAFETY ZONES AS DEFAULT?
            
            % set up camera
            if ~g.simulate
                imaqreset;% make sure there are no initialised video objects
                g.vid=videoinput('winvideo',1,'YUY2_720x576');
                set(g.vid,'ReturnedColorSpace','rgb');
                % having the preview window open seems to make frame acquisition faster
                if nargin>=7 && showvidpreview
                    preview(g.vid); % line commented out - AD
                end
                start(g.vid);
            end
            %             pause(4) % WILL THIS BE LONG ENOUGH?
            g.rundata.acuity = acuity;
            g.rundata.cent = [362.4114 295.4111];
            g.rundata.inner_radius = 111.6857;
            g.rundata.outer_radius = 180;
            
        end
        
        function delete(g)
            % disconnect from robot and unload library
            g.closeGantry();
            % close video stream
            if isequal(class(g.vid),'videoinput')
                stop(g.vid)
                delete(g.vid)
            end
        end
        
        function pos = getPosition(g, sel)
            % SEE NOTES FOR GETSPEED
            
            % create pointer for Advantech return value
            p = libpointer('longPtr',0);
            % get X position
            e = calllib('ADS1240', 'P1240GetTheorecticalRegister', 0, 1, p);
            pos(1) = get(p,'Value');
            % get Y position
            e = calllib('ADS1240', 'P1240GetTheorecticalRegister', 0, 2, p);
            pos(2) = get(p,'Value');
            % get Z position
            e = calllib('ADS1240', 'P1240GetTheorecticalRegister', 0, 4, p);
            pos(3) = get(p,'Value');
            % return as column vector
            pos = double(pos)';
            
            if sel == 1
                pos = g.pulses2mm(pos,'XYZ');
            end
            
        end
        
        %         function vel = getVelocity(g)
        % THIS FUNCTION SEEMED A GOOD IDEA, BUT GIVEN THAT THE MACHINE (OR THE PCI CARD) LIES ABOUT ITS POSITION AS WELL AS ITS SPEED, THIS MAY BE A WASTE OF TIME
        %         end
        
        function speed = getSpeed(g, sel)
            % what about errors from the function calls below??
            % SHOULD THEY BE REPORTED?
            % SHOULD THE MACHINE WIND DOWN?
            
            % create pointer for Advantech return value
            p = libpointer('uint32Ptr',0);
            % get X speed
            e = calllib('ADS1240', 'P1240GetSpeed', 0, 1, p);
            speed(1) = get(p,'Value');
            % get Y speed
            e = calllib('ADS1240', 'P1240GetSpeed', 0, 2, p);
            speed(2) = get(p,'Value');
            % get Z speed
            e = calllib('ADS1240', 'P1240GetSpeed', 0, 4, p);
            speed(3) = get(p,'Value');
            % return as column vector
            speed = double(speed * g.speedRatio)';
            
            if sel == 1
                speed = g.pulses2mm(speed,'XYZ');
            end
        end
        
        function frame = getFrame(g)
            x = 0;y = 0;z = 0;
            theta = 0;
            frame = getview(getsnapshot(g.vid),x,y,z,theta,g.rundata);
        end
        
        function frame = getRawFrame(g)
            if g.simulate
                frame = randi(255,576,720,3,'uint8');
            else
                frame = getsnapshot(g.vid);
            end
        end
        
        function time = getTime(g)
            time = toc(g.ticID);
        end
        
        function [pos,vel,time,frame] = getData(g,sel,saveData,saveFrame)
            % NEED TO DEAL WITH SAVING...
            
            time = g.getTime();
            pos = g.getPosition(1);
            frame = g.getFrame();
            
            sel = 0; % getVelocity() IS NOT READY, AND MAY NEVER BE...
            if sel
                vel = g.getVelocity(1);
            else
                vel = g.getSpeed(1);
            end
            
            if saveData || saveFrame
                if g.saveDir == ' '
                    warning('Data cannot be saved. You should use ''startSimulation()'' to set up timer and directory.')
                else
                    if saveData
                        filepath = [g.saveDir '\pos_vel_time.dat'];
                        fileID = fopen(filepath,'a');
                        formatSpec = '%6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %9.4f \n';
                        data = [pos(1) pos(2) pos(3) vel(1) vel(2) vel(3) time];
                        fprintf(fileID,formatSpec,data);
                        fclose(fileID);
                    end
                    if saveFrame
                        filepath = [g.saveDir '\' num2str(g.frameCounter) '.bmp'];
                        imwrite(frame, filepath);
                        g.frameCounter = g.frameCounter + 1;
                    end
                end
            end
        end
        
        function [pos, realVel, time] = contMove(g, vel)
            
            if g.disableZ
                vel(3) = 0;
            end
            
            vel = g.mm2pulses(vel, 'XYZ');
            lastVe = g.lastVel; % g.mm2pulses(g.lastVel, 'XYZ');
            realSpeed = g.getSpeed(0);
            pos = g.getPosition(0);
            
            % TIME IS RECORDED WITH REFERENCE TO THE TIME OF THE OBJECT'S
            % CREATION
            time = toc(g.ticID);
            
            % last velocity is used here only to keep track of motor directions
            % lastVel
            % dir2sign(lastVel < 0)
            % this: 'dir2sign(lastVel < 0)' looks wrong to me but seems to be working...
            realVel = realSpeed .* g.dir2sign(lastVe < 0);
            
            % calculate acceleration - here or in another function?
            acc = vel - realVel;
            
            % cap jerk??
            % it could be included but commented out, or with quite a high value just
            % to avoid massive acceleration jumps
            % CAPPING JERK WILL ALSO REQUIRE LAST ACCELERATION TO BE PASSED IN?
            
            % cap acceleration
            acc = g.capAccel(acc);
            
            % apply acceleration
            vel = realVel + acc;
            
            % cap velocity according to maximums
            vel = g.capVelocity(vel);
            
            % cap velocity according to soft limits
            %             vel = g.respectBoundaries(pos,lastVe,vel);
            
            % SET MOTOR SPEEDS!!!!! using contSpeed !!!!!!!
            speed = abs(vel);
            g.motorSpeed(1, speed(1));
            g.motorSpeed(2, speed(2));
            g.motorSpeed(4, speed(3));
            
            % dir = sign2dir(sign(vel));
            direction = g.sign2dir(vel);
            % lastVel
            % lastDir = sign2dir(sign(lastVel));
            lastDir = g.sign2dir(lastVe);
            
            % errors??
            if direction(1) ~= lastDir(1)
                e = calllib('ADS1240', 'P1240MotStop', 0, 1, 1);
            end
            
            if direction(2) ~= lastDir(2)
                e = calllib('ADS1240', 'P1240MotStop', 0, 2, 2);
            end
            
            if direction(3) ~= lastDir(3)
                e = calllib('ADS1240', 'P1240MotStop', 0, 4, 4);
            end
            
            % if any motor is idle then enable it according to velocity directions
            if ~calllib('ADS1240', 'P1240MotAxisBusy', 0, 1)
                g.motorDir(1, direction(1));
            end
            
            if ~calllib('ADS1240', 'P1240MotAxisBusy', 0, 2)
                g.motorDir(2, direction(2));
            end
            
            if ~calllib('ADS1240', 'P1240MotAxisBusy', 0, 4)
                g.motorDir(4, direction(3));
            end
            
            % note that the velocity returned is the commanded one, not the measured!!!
            % should return both!!!
            % realVel is now returned, as it should be with the position and timestamp,
            % however, it must be remembered that from the time of measurement to the
            % end of this function it may have been changed!
            g.lastVel = vel; % g.pulses2mm(vel, 'XYZ');
            realVel = g.pulses2mm(realVel, 'XYZ');
            pos = g.pulses2mm(pos,'XYZ');
            
            % I'M NOT SURE ABOUT lastVel HERE - IT SEEMS TO BE RECORDING
            % THE LAST VELOCITY COMMAND, WHICH APPEARS TO BE ONLY FOR THE PURPOSES
            % OF KEEPING TRACK OF THE MOTORS DIRECTIONS - HOWEVER, THIS
            % MAY COME UNSTUCK IN INSTANCES WHEN THE MOTOR
            % CANNOT IMMEDIATELY CHANGE DIRECTION -
            %
            % - OR PERHAPS NOT, DUE TO THE CHECK direction(1) ~= lastDir(1)
            % FOR STOPPING MOTORS - EITHER WAY, THIS NEEDS CHECKING
            % THOROUGHLY, ON THE ROBOT AND ON PAPER - IF THE LOGIC CAN BE
            % SIMPLIFIED, THEN SIMPLIFY IT!
        end
        
        function startSimulation(g,topLevel)
            
            % AS WELL AS THIS, I NEED TO STORE THE DIRECTORY NAME SOMEWHERE
            % SO THAT I CAN SAVE TO IT!
            g.saveDir = [topLevel '\' datestr(clock,30)];
            [success,msg,msgID] = mkdir(g.saveDir);
            if ~success
                disp('Simulation directory not created')
                error(msg)
            end
            g.ticID = tic;
            g.frameCounter = 1;
            
        end
        
        function move(g,pos)
            pos = pos(:);
            
            if any(pos < 0 | pos > g.limitmm)
                error('position out of range!')
            end
            
            if g.simulate
                fprintf('SIMULATE: MOVING TO [%g,%g,%g]\n',pos(1),pos(2),pos(3))
            else
                pos = pos+g.alex_offset;
                
                if g.disableZ
                    pos(3) = 0;
                end
                
                e = calllib('ADS1240', 'P1240SetDrivingSpeed', 0, 0, 1000); % for line/arc interp?
                % somewhere near 1000 may be the minimum here - set this figure too small
                % and it seems the old figure remains set!!!
                e = calllib('ADS1240', 'P1240SetStartSpeed', 0, 0, 125); % for line/arc interp?
                
                pos = g.mm2pulses(pos,'XYZ');
                
                % AxisNumErr 0x0006 Function The assigned axis number error
                e = calllib('ADS1240', 'P1240MotLine', 0, 7, 7, pos(1), pos(2),pos(3), 0);
                
                while calllib('ADS1240', 'P1240MotAxisBusy', 0, 7)
                    % hold up program execution while axes are still in motion
                end
            end
        end
        
        function [posHist, speedHist, time] = windDown(g)
            
            % one problem with this - if an axis is in motion but below some value then
            % an error is returned and the axis is not stopped (because of while (x_vel > 10) || (y_vel > 10) || (z_vel > 10)??)
            
            speed = g.getSpeed(0);
            posHist = g.getPosition(1);
            speedHist = g.pulses2mm(speed,'XYZ');
            time = g.getTime();
            
            % note that this function deals in pulses
            velMin = 10;
            decel = 1500;   %  900
            
            % note: the last velocities (converted) are only 8 for axes
            % that stop early but are 45 for the last to stop - because there is a further
            % deceleration after this point and the conditions for exiting the loop are
            % based on the raw values
            while sum(speed > velMin)
                
                speed = speed - decel
                
                % impose minimum velocity - should this be in a function?
                %     speed >= velMin
                %     speed .* (speed >= velMin)
                %     speed < velMin
                %     velMin * (speed < velMin)
                speed = (speed .* (speed >= velMin)) + (velMin * (speed < velMin));
                
                % NEEDS CHANGING TO A WRAPPER FUNCTION - ALSO, CAN'T THIS BE DONE IN
                % ONE FUNCTION CALL?
                ex = calllib('ADS1240', 'P1240MotChgDV', 0, 1, speed(1));
                ey = calllib('ADS1240', 'P1240MotChgDV', 0, 2, speed(2));
                ez = calllib('ADS1240', 'P1240MotChgDV', 0, 4, speed(3));
                
                % is this a good period?
                pause(0.1)
                
                % MAKE IT CLEAR WHERE THIS CALC COMES FROM
                speed = g.getSpeed(0);
                speedHist = [speedHist g.pulses2mm(speed,'XYZ')];
                
                time = [time; g.getTime]; % this time, take timestamp in the middle of all readings
                posHist = [posHist g.getPosition(1)];
                
            end
            
            posHist = double(posHist);
            speedHist = double(speedHist);
            
            %             current_dir = pwd
            %             cd C:\Users\gantry\Desktop\chris\data
            %             save('history.mat', 'posHist', 'speedHist', 'time');
            %             cd(current_dir)
            
            % PUT IN A WRAPPER??
            es = calllib('ADS1240', 'P1240MotStop', 0, 7, 7);
            
        end
        
        function home_gantry(g, disableZ)
            if g.simulate
                disp('SIMULATE: HOMING GANTRY')
            else
                % this will be the place to set up the gantry object, with conversion
                % methods etc.
                % safe speeds, axis limits, accelerations and so on also belong to that
                % object
                
                %% open PCI library
                %             disp(' ') ; disp('Accessing gantry robot'); disp(' ')
                %             g.openGantry()
                
                % AFTER THE DEVICE IS OPENED!
                % IT MAY BE A GOOD IDEA TO SET THE POSITIONS TO SOME (X LARGE) VALUE SO THAT AT THE
                % END IF THE AXES ARE ALL AT 0 THEN THEY MUST HAVE GOT HOME
                
                %% move z-axis up to safe position
                if ~disableZ
                    disp('   Driving z-axis to upper limit switch')
                    e = calllib('ADS1240', 'P1240MotChgDV', 0, 4, 1000); % set z-axis speed
                    if e
                        g.gantryErrors(e, 'setting z-axis motor speed')
                    end
                    e = calllib('ADS1240', 'P1240MotCmove', 0, 4, 0); % drive z-axis up to its limit
                    if e
                        g.gantryErrors(e, 'driving z-axis up to maximum limit')
                    end
                    
                    % hold up execution while Z axis is in motion
                    while calllib('ADS1240', 'P1240MotAxisBusy', 0, 7) % DOES '7' COVER ALL THREE AXES?
                    end
                else
                    disp(' ')
                    reply = input('Z-axis disabled mode. You are about to home in X and Y without first retracting in Z. Is robot''s path clear? y/n [y]:','s');
                    if isempty(reply)
                        reply = 'n';
                    end
                    if reply ~= 'y'
                        g.closeGantry()
                        error('Gantry initialisation cancelled')
                    end
                end
                
                
                % IS IT POSSIBLE TO CHECK WHETHER THE AXIS IS ON THE LIMIT SWITCH?????
                
                %% home in XY plane
                disp('   Homing x-axis')
                e = calllib('ADS1240', 'P1240MotHome', 0, 1); % home x axis - position seems to be automatically
                if e
                    g.gantryErrors(e, 'homing x-axis')
                end
                disp('   Homing y-axis')
                e = calllib('ADS1240', 'P1240MotHome', 0, 2); % home y
                if e
                    g.gantryErrors(e, 'homing y-axis')
                end
                
                % hold up execution while homing XY axes
                % THIS MAY BE DONE BETTER BY P1240MotHomeStatus? NOT SURE HOW TO CHECK
                % THIS... PERHAPS E-STOP DURING HOMING MOVE
                
                % ACTUALLY, I'M NOT SURE ABOUT THIS HOMESTATUS - WHETHER IT MEANS THE MC
                % IS AT HOME, OR PRESENTLY HOMING
                
                % create pointer for Advantech return value
                p = libpointer('uint32Ptr',0);
                
                while calllib('ADS1240', 'P1240MotAxisBusy', 0, 7)
                    % does this need to be performed axis by axis?
                    %                 e = calllib('ADS1240', 'P1240MotHomeStatus', 0, 1, p);
                    %                 xstatus = get(p,'Value');
                    %                 disp(['X status ' num2str(xstatus)])
                    
                    %                 e = calllib('ADS1240', 'P1240MotHomeStatus', 0, 2, p);
                    %                 ystatus = get(p,'Value');
                    %                 disp(['Y status ' num2str(ystatus)])
                end
                disp('     x and y-axes are home')
                
                %% home Z axis
                if ~disableZ
                    disp('   Homing z-axis')
                    e = calllib('ADS1240', 'P1240MotHome', 0, 4); % home z
                    if e
                        g.gantryErrors(e, 'homing z-axis')
                    end
                    
                    while calllib('ADS1240', 'P1240MotAxisBusy', 0, 7)
                        %                 e = calllib('ADS1240', 'P1240MotHomeStatus', 0, 4, p);
                        %                 zstatus = get(p,'Value');
                        %                 disp(['Z status ' num2str(zstatus)])
                    end
                end
                disp('     z-axis is home')
                
                % confirm positions are all 0? this guarantees nothing!!!!!!!
                
                disp(' '); disp('Robot is ready')
            end
        end
        
        % public methods end
    end
    
    %% private methods
    methods(Access = private)
        
        function d = mm2pulses(g, d, axes)
            d = d .* g.setRatio(d, axes);
        end
        
        function d = pulses2mm(g, d, axes)
            d = d ./ g.setRatio(d, axes);
        end
        
        function r = setRatio(g, d, axes)
            
            if ~isequal(size(axes'), size(d))
                error('Size of vector and dimension selector must be equal')
            end
            
            switch axes
                case 'XYZ'
                    r = g.ratio;
                case 'XY'
                    r = g.ratio(1:2);
                case 'YZ'
                    r = g.ratio(2:3);
                case 'XZ'
                    r = g.ratio([1 3]);
                case 'X'
                    r = g.ratio(1);
                case 'Y'
                    r = g.ratio(2);
                case 'Z'
                    r = g.ratio(3);
                otherwise
                    error('Invalid dimension specification')
            end
            
        end
        
        function limitWarning(g, axis, vel_sign, order)
            if vel_sign == 1
                sign_char = '+';
            else
                sign_char = '-';
            end
            if order == 1
                lim = 'velocity';
            else
                lim = 'acceleration';
            end
            warning('gantry:limitmaxed',['Command for ' g.axisNum2Char(axis) '-axis ' lim ' exceeds maximum in ' sign_char ' direction'])
        end
        
        function ax = axisNum2Char(g, axis)
            switch axis
                case 1
                    ax = 'X';
                case 2
                    ax = 'Y';
                case 3
                    ax = 'Z';
            end
        end
        
        function readIni(g)
            % read in conversion ratio, from mm to pulses
            g.ratio = g.getVals(g.getStrings('ratio'));
            % maximum operating velocities and accelerations
            g.maxVel = g.getVals(g.getStrings('maxVel'));
            g.maxAccel = g.getVals(g.getStrings('maxAccel'));
            % axis limits, in pulses
            g.limit = g.getVals(g.getStrings('limit'));
            g.limitmm = floor((g.limit./g.ratio) - 2*g.alex_offset);
            % axis software limit parameters
            keys = {'soft_limits', '', 'zone1';
                'soft_limits', '', 'zone1_max_accel';
                'soft_limits', '', 'zone2'};
            [readsett,result] = inifile('Gantry.ini','read',keys);
            zone_vals = g.getVals(readsett);
            g.zone1 = zone_vals(1);
            g.zone1_max_accel = zone_vals(2);
            g.zone2 = zone_vals(3);
        end
        
        function readsett = getStrings(g,section)
            subsection = '';
            keys = {section, subsection, 'x';
                section, subsection, 'y';
                section, subsection, 'z'};
            [readsett,result] = inifile('Gantry.ini','read',keys);
        end
        
        function vals = getVals(g,readsett)
            % always return values as a column vector
            s = size(readsett,1);
            vals = zeros(s,1);
            for t = 1:s
                if isequal('',readsett{t})
                    error('Not all values were read successfully')
                else
                    vals(t) = str2double(readsett{t});
                end
            end
        end
        
        function printFields(g)
            disp('mm to pulses conversion factor')
            disp(num2str(g.ratio));
            disp(' ')
            
            disp('Measured speed to speed in pulses conversion factor')
            disp(num2str(g.speedRatio));
            disp(' ')
            
            disp('Maximum axis velocities (pulses)')
            disp(num2str(g.maxVel));
            disp(' ')
            
            disp('Maximum axis accelerations (pulses)')
            disp(num2str(g.maxAccel));
            disp(' ')
            
            disp('Hardware axis limits (pulses)')
            disp(num2str(g.limit));
            disp(' ')
            
            disp(['Zone 1 width: ' num2str(g.zone1) 'mm'])
            disp(['Zone 1 maximum acceleration: ' num2str(g.zone1_max_accel) 'mm'])
            disp(['Zone 2 width: ' num2str(g.zone2) 'mm'])
        end
        
        function direction = sign2dir(g, vel)
            direction = (1 - sign(vel)) / 2;
            direction = direction .* ~(direction == 0.5); % if direction == 0.5, set it to 0
        end
        
        function vel_sign = dir2sign(g, direction)
            vel_sign = 1 - (direction * 2);
        end
        
        % THIS FUNCTION CAN BE A PROBLEM - FOR EXAMPLE, YOU CAN'T HOME THE
        % MACHINE AND THEN GO STRAIGHT INTO CONTINUOUS MODE...
        function vel = respectBoundaries(g, pos, lastVel, vel)
            % what happens if the position limits are exceeded?
            error('This function is not working')
            pos
            g.limit_safe
            over_lim = pos > g.limit_safe
            under_lim = pos < g.origin_safe;
            % duplicated code below is untidy...
            if sum(over_lim)
                % even if an axis hits a hard limit, the others will still operate
                g.windDown
                % indicate which axis has committed which violation!
                for t = 1:3
                    if over_lim(t)
                        error([g.axisNum2Char(t) '-axis exceeds maximum software limit'])
                    end
                end
                % i have used elseif here, because although it is possible to have one
                % or more axes over max limits and others under minimum limits,
                % still this point would not be reachable in that case
            elseif sum(pos < under_lim)
                g.windDown
                % indicate which axis has committed which violation!
                for t = 1:3
                    if over_lim(t)
                        error([g.axisNum2Char(t) '-axis exceeds minimum software limit'])
                    end
                end
                
            end
            
            % within the regions set by zone1 the robot will begin to
            % decelerate
            for t = 1:3
                % this code is for approaching LMT+
                if (pos(t) > (g.limit(t) - g.zone1)) && (lastVel(t) > 0)
                    disp([g.axisNum2Char(t) '-axis is close to the maximum limit. Decelerating'])
                    %         pos
                    v_max  = (g.limit(t) - pos(t)) * g.zone1_max_accel;
                    if lastVel(t) > v_max
                        vel(t) = v_max;
                    end
                    % this code is for approaching origin
                elseif (pos(t) < g.zone1) && (lastVel(t) < 0)
                    disp([g.axisNum2Char(t) '-axis is close to the minimum limit. Decelerating'])
                    %         pos
                    v_maxR = - pos(t) * g.zone1_max_accel;
                    if lastVel(t) < v_maxR
                        vel(t) = v_maxR;
                    end
                end
            end
        end
        
        function vel = capVelocity(g, vel)
            for t = 1:3
                if vel(t) > g.maxVel(t)
                    vel(t) = g.maxVel(t);
                    g.limitWarning(t,1,1);
                elseif vel(t) < -g.maxVel(t)
                    vel(t) = -g.maxVel(t);
                    g.limitWarning(t,-1,1);
                end
            end
        end
        
        function accel = capAccel(g, accel)
            for t = 1:3
                if accel(t) > g.maxAccel(t)
                    accel(t) = g.maxAccel(t);
                    g.limitWarning(t,1,2);
                elseif accel(t) < -g.maxAccel(t)
                    accel(t) = -g.maxAccel(t);
                    g.limitWarning(t,-1,2);
                end
            end
        end
        
        function motorSpeed(g, ax, speed)
            %MOTORSPEED a function to set the speed of a single motor for
            %continuous motion. Note that this function does not set the motor
            %direction.
            if speed < 10 % this prevents PCI error 25, and seems to have negligible effect. It can easily be checked that it does something by making it larger...
                speed = 0;
            end
            e = calllib('ADS1240', 'P1240MotChgDV', 0, ax, speed); % set axis speed
            if e
                g.gantryErrors(e, 'setting motor speed')
            end
        end
        
        function motorDir(g, ax, direction)
            %MOTORDIR a function to set the direction of a single motor.
            %Note: a motor's direction may not be set when the motor is
            %running. The motor must be stopped before this function is
            %called.
            e = calllib('ADS1240', 'P1240MotAxisBusy', 0, ax);
            if ~e
                e = calllib('ADS1240', 'P1240MotCmove', 0, ax, ax * direction);
            else
                % some returns from P1240MotAxisBusy are not errors per se,
                % but all non-zero returns at this point indicate failure
                % in this software level - this function should never be
                % called for a running motor.
                windDown
                warning('Axis was not ready for motor direction change')
            end
            if e
                g.gantryErrors(e, 'setting motor direction')
            end
        end
        
        function closeGantry(g)
            %CLOSEGANTRY Close the gantry robot.
            %   A function to close the PCI device which controls the gantry
            %   robot and unload the associated library.
            %
            %   This function will throw an error if the library is open but the device
            %   is already closed. While this situation is not dangerous, it is
            %   reported because it should not usually occur and may indicate that
            %   something else has gone wrong. An error will also be thrown if the
            %   library is not unloaded successfully. This is included for completeness
            %   but it has never been observed and it may not even be possible.
            
            if libisloaded('ADS1240')
                e = calllib('ADS1240', 'P1240MotDevClose', 0);
                if e
                    g.gantryErrors(e, 'closing PCI device')
                else
                    disp(' '); disp('   PCI device is now closed')
                end
                
                unloadlibrary 'ADS1240'
                if libisloaded('ADS1240')
                    error('Library was not unloaded successfully')
                end
            else
                disp(' '); disp('PCI device was already closed')
            end
            disp('   Library is now unloaded');disp(' ')
            disp('Robot is disconnected');disp(' ')
        end
        
        function openGantry(g)
            %OPENGANTRY Open the gantry robot.
            %   Load the Advantech CNC shared library and open the PCI device for
            %   use. When these two steps are completed MATLAB can control the gantry
            %   robot directly using the shared library functions.
            %
            %   The call to 'loadlibrary' produces a lot of messages in the 'warnings'
            %   character array, which are not displayed here or returned. The warnings
            %   refer to defined types in 'win.h'. It appears that MATLAB replaces
            %   these types with defaults and that this is not causing any issues.
            %
            %   Note: the header file 'ADS1240_1.h' was edited to include 'windows.h'
            %   and to skip over some function prototypes which appear to refer to
            %   functions not actually included in our 'ADS1240.dll' library. I CAN'T
            %   RECALL RIGHT NOW WHETHER I HAD TO CHANGE THE DLL IN ANY WAY, ALTHOUGH
            %   IT'S HIGHLY UNLIKELY (I PROBABLY WOULDN'T KNOW HOW)
            
            % open the library
            [notfound,warnings] = loadlibrary('C:\Windows\System32\ADS1240.dll', 'ADS1240_1.h');
            if libisloaded('ADS1240')
                disp('   Library is now loaded')
            else
                error('The library was not successfully loaded')
            end
            
            % open the PCI device
            e = calllib('ADS1240', 'P1240MotDevOpen', 0);
            if e
                g.gantryErrors(e, 'opening PCI device')
            else
                disp('   PCI device is now open')
            end
            
        end
        
        function gantryErrors(g, errorNo, message)
            error(['PCI-1240 error ' num2str(errorNo) ' was received when ' message]);
        end
        
        % private methods end
    end
    
    
end