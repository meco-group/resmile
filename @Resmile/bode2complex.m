function m = bode2complex(amplitudes, phases)
    % Convert amplitudes and phases returned by the `bode` function into complex values.
    m = amplitudes.*exp(1i.*deg2rad(phases));
end
