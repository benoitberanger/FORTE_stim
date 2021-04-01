function [ cash ] = Cash( )
global S

cash = Wav( fullfile(pwd,'wav',S.Parameters.Forte.Outcome.fname_cash) );

cash.LinkToPAhandle( S.PTB.Playback_pahandle );
cash.Resample( S.Parameters.Audio.SamplingRate );
cash.Normalize();

end % function
