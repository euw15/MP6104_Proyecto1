function calculateReplicate(amplitude, phase)
    replicaSampleIndex = windowSample*currentWindowN-phase;
    if(replicaSampleIndex < 1 ||   replicaSampleIndex > audioInfo.TotalSamples)
      replicaSample = 0;
    endif
    else
      replicaSample = amplitude*audioSamples(replicaSampleIndex);
    endif
    
    audioSamples(windowSample*currentWindowN)+replicaSample;
  
  
  
  
endfunction
