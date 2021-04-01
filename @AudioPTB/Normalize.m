function Normalize( obj )

obj.signal = obj.signal / max( max( abs( obj.signal ) , [], 2 ) );

end % function
