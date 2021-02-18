function Draw( obj, high_or_low )

if nargin < 2
    high_or_low = '';
end

switch high_or_low
    case 'high'
        obj.high_reward.Draw;
        obj.total.value = obj.total.value + 10.00;
    case 'low'
        obj.low_reward.Draw;
        obj.total.value = obj.total.value + 00.01;
    case ''
        obj.total.value = 0;
end

obj.total.content = sprintf('%.02f €',obj.total.value);
obj.total.Draw()

end % function
