clc;
%********************************************************
%**********   Extraccion de Audio        ****************
%********************************************************
[audioSamples,fs] = audioread("AudioSamples/pointless.wav");

audioInfo = audioinfo("AudioSamples/pointless.wav");

%*********************************************************
%**********   Enventadanado        ***********************
%*********************************************************
input_Windows = 'Numero de Ventanas ';
n_windows = input(input_Windows);

if(n_windows <= 0)
  printf("El numero de ventanas debe ser mayor a 0\n");
  return;
endif

windowsSize = audioInfo.TotalSamples/n_windows;

%*********************************************************
%**************    Multiplexado  *************************
%*********************************************************
s_a0 = 'a0';
d_a0 = input(s_a0);

s_a1 = 'a1';
d_a1 = input(s_a1);

s_b0 = 'b0';
s_b0 = input(s_b0);

s_b1 = 'b1';
d_b1 = input(s_b1);

s_metadatos = 'Metadatos';
d_metadatos = input(s_metadatos);
v_ascii     = toascii (d_metadatos);

for samplesIndex=1:8
  
  index             = fix(abs(samplesIndex-1)/7)+1;
  currentLetter     = v_ascii(index);
  currentLetterBits = flip ( bitget (currentLetter, 7:-1:1));
  currentBit        = currentLetterBits(mod((samplesIndex-1),7)+1);
  
  if(currentBit)
  
  
  
  endif
  else

  endif
  %y_n = audioSamples(samples)+d_a0*audioSamples(samples-s_b0);
  %y_n = audioSamples(samples)+d_a1*audioSamples(samples-s_b1);
endfor
