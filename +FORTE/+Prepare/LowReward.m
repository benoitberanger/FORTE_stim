function [ lowreward ] = LowReward( )
global S

lowreward = Wav( fullfile(pwd,'wav',S.Parameters.Forte.Outcome.fname_lowreward) );

lowreward.LinkToPAhandle( S.PTB.Playback_pahandle );
lowreward.Resample( S.Parameters.Audio.SamplingRate );
lowreward.Normalize();

end % function
