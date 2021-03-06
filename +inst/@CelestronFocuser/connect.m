function F=connect(F,Port)
% connect to a focus motor on the specified Port, try all ports if
%  Port omitted
    if ~exist('Port','var') || isempty(Port)
        for Port=seriallist
            try
                % look for one NexStar device on every
                %  possible serial port. Pity we cannot
                %  look for a named (i.e. SN) unit
                F.connect(Port);
                if isempty(F.lastError)
                    return
                else
                    delete(instrfind('Port',Port))
                end
            catch
                F.report("no Celestron Focus Motor found on "+Port+'\n')
            end
        end
    end

    try
        delete(instrfind('Port',Port))
    catch
        F.lastError=['cannot delete Port object ' Port ' -maybe OS disconnected it?'];
    end

    try
        F.serial_resource=serial(Port);
        % serial has been deprecated in 2019b in favour of
        %  serialport... all communication code should be
        %  transitioned...
    catch
        F.lastError=['cannot create Port object ' Port ];
    end

    try
        if strcmp(F.serial_resource.status,'closed')
            fopen(F.serial_resource);
            set(F.serial_resource,'BaudRate',19200,'Terminator',{'',10},'Timeout',1);
            % (quirk: write terminator has to be 10 so that 10 in output
            %  binary data is sent as such)
        end
        F.Port=F.serial_resource.Port;
        check_for_focuser(F);
    catch
        F.lastError="Port "+Port+' cannot be opened';
        delete(instrfind('Port',Port)) % (tcatch also error here?)
    end
    end
