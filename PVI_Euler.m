clear; clc; close all;
% --- Configuración ---
F = @(x, y) 1 - y ./ (2 + 1.5 * sin(4*pi*x));
x_end = 2;
y0 = 1;
h_values = [1, 0.1, 0.01, 0.001, 0.0001];
colors = jet(length(h_values));
% Configuración del GIF
filename = 'evolucion_euler_step_by_step.gif';
frames_per_curve = 30; % Queremos aprox 30 frames por cada curva para que sea fluido pero ligero
% --- Preparar la Figura ---
fig = figure('Color', 'w', 'Position', [100, 100, 800, 600]);
hold on; grid on;
xlim([0, 2]);
ylim([1, 1.8]); % Límites fijos importantes para que no baile la imagen
xlabel('x'); ylabel('f(x)');
title('Construcción dinámica del Método de Euler');
% Leyenda vacía inicial para ir rellenándola
lgd = legend('Location', 'northwest');
% --- Bucle Principal ---
for k = 1:length(h_values)
   h = h_values(k);
  
   % 1. Pre-calcular toda la curva para este h
   % Es más eficiente calcular primero y animar después
   x = 0:h:x_end;
   y = zeros(size(x));
   y(1) = y0;
   for i = 1:length(x)-1
       y(i+1) = y(i) + h * F(x(i), y(i));
   end
  
   % 2. Crear el objeto gráfico vacío para esta curva
   % Usamos un 'handle' (p) para ir actualizando sus datos
   curve_name = sprintf('h = %.4f', h);
   p = plot(nan, nan, 'Color', colors(k,:), 'LineWidth', 1.5, 'DisplayName', curve_name);
  
   % 3. Calcular el "salto" de frames
   % Si hay muchos puntos, nos saltamos algunos para no eternizar el GIF
   num_points = length(x);
   if num_points < frames_per_curve
       step_jump = 1; % Si hay pocos puntos, dibujamos todos
   else
       step_jump = floor(num_points / frames_per_curve);
   end
  
   % 4. Bucle de Animación (Dibujado progresivo)
   % Recorremos los puntos y actualizamos la gráfica
   for j = 1:step_jump:num_points
      
       % Actualizamos los datos de la línea hasta el punto actual j
       set(p, 'XData', x(1:j), 'YData', y(1:j));
      
       % Actualizamos título
       title({['Generando aproximación con h = ' num2str(h)]; ...
              ['Progreso: ' num2str(round(j/num_points*100)) '%']});
      
       % Captura del GIF
       drawnow;
       frame = getframe(fig);
       im = frame2im(frame);
       [imind, cm] = rgb2ind(im, 256);
      
       if k == 1 && j == 1
           imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
       else
           imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
       end
   end
  
   % 5. Asegurar que el último punto se dibuje (por si el salto no fue exacto)
   set(p, 'XData', x, 'YData', y);
   drawnow;
  
   % Capturamos el estado final de la curva un poco más de tiempo (0.5s)
   frame = getframe(fig);
   im = frame2im(frame);
   [imind, cm] = rgb2ind(im, 256);
   imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
  
end
fprintf('GIF generado exitosamente: %s\n', filename);
