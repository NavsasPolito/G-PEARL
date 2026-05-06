function action1(src,event)
% This callback toggles the visibility of the line of a plot

if strcmp(event.SelectionType,"normal") == 1
    if strcmp(event.Peer.Visible,'on')   % If current line is visible
        event.Peer.Visible = 'off';      %   Set the visibility to 'off'
    else                                 % Else
        event.Peer.Visible = 'on';       %   Set the visibility to 'on'
    end

elseif strcmp(event.SelectionType,"extend") == 1
    str = unique(src.String);

    for i = 1:length(src.String)
        h = findobj(gca,'flat','-depth',2,'DisplayName',string(str(i)));
        
        for j = 1:numel(h)
            if strcmp(h(j).Visible,'on')
                h(j).Visible = 'off';
            else
                h(j).Visible = 'on';
            end
        end
    end
elseif strcmp(event.SelectionType,"open") == 1
    str = unique(src.String);

    for i = 1:length(src.String)
        h = findobj(gca,'flat','-depth',2,'DisplayName',string(str(i)));

        for j = 1:numel(h)
            if contains(h(j).DisplayName,["L1","G1","E1","B1"])
                h(j).Visible = 'on';
            else
                h(j).Visible = 'off';
            end
        end
    end
end