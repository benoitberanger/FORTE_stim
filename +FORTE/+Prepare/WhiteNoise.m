function [ whitenoise ] = WhiteNoise( cash )

whitenoise          = AudioPTB();
whitenoise.fs       = cash.fs;
whitenoise.signal   = randn(1,size(cash.signal,2));
whitenoise.signal   = [whitenoise.signal;whitenoise.signal];  % use mono signal in both speakers (stereo)
whitenoise.Normalize();
whitenoise.signal   = whitenoise.signal/4;
whitenoise.duration = cash.duration;
whitenoise.time     = cash.time;
whitenoise.pahandle = cash.pahandle;

end % function
