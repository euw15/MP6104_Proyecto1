clear;
clc;
%********************************************************
%**********   Constantes        *************************
%********************************************************

bitsPerChar = 7;
%********************************************************
%**********   Extraccion de Audio        ****************
%********************************************************
[file, path] = uigetfile ('*.wav',"Seleccione archivo de audio");
if isequal(file,0)
   disp('Archivo invalido');
else
   disp(['Archivo: ', fullfile(path,file)]);
end

[audioSamples,fs] = audioread(fullfile(path,file));

audioInfo         = audioinfo(fullfile(path,file));

%*********************************************************
%**************  Parametros de entrada  ******************
%*********************************************************
input_Windows = 'Numero de Ventanas ';
n_windows     = input(input_Windows);

s_a0 = 'a0 ';
d_a0 = input(s_a0);

s_a1 = 'a1 ';
d_a1 = input(s_a1);

s_b0 = 'b0 ';
d_b0 = input(s_b0);

s_b1 = 'b1 ';
d_b1 = input(s_b1);

%*********************************************************
%**************  Verificacion de Entradas  ***************
%*********************************************************
if(n_windows <= 0)
  printf("El numero de ventanas debe ser mayor a 0\n");
  return;
endif

if(bitsPerChar >= n_windows)
  printf("Se necesitan mas ventanas para representar un char\n");
  return;
endif

if(n_windows >= audioInfo.TotalSamples)
  printf("Mas ventanas que muestras\n");
  return;
endif

if(d_b0 <= 0 || d_b1 <= 0)
  printf("d debe ser mayor que cero\n");
  return;
endif


windowsSize = fix(audioInfo.TotalSamples/n_windows);

for i = 1:7
figure();
yx = audioSamples(windowsSize*(i-1)+1:windowsSize*(i-1)+windowsSize);

X = fft(yx);
X_ln = log(X);

X_ln_2 = X_ln .* X_ln;

rxx = ifft(X_ln_2);

y = abs(rxx);

ceroAmplitude = max(y(d_b0-4:d_b0+4));
oneAmplitude = max(y(d_b1-4:d_b1+4));

if(ceroAmplitude < oneAmplitude)
  bits(i) = 1;
else
  bits(i) = 0;
endif

plot(abs(rxx));
endfor
