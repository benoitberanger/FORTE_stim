function [ highreward ] = HighReward( )
global S

highreward = Wav( fullfile(pwd,'wav',S.Parameters.Forte.Outcome.fname_highreward) );

highreward.LinkToPAhandle( S.PTB.Playback_pahandle );
highreward.Resample( S.Parameters.Audio.SamplingRate );
highreward.Normalize();

end % function
