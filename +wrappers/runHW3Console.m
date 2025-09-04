%RUNHW3CONSOLE  Run the HW3 barrier/QP console demonstration.
%   RUNHW3CONSOLE() invokes the barrier method module in opt.barrier.

if exist('opt.barrier.barrierMethodModule','file') == 2
    opt.barrier.barrierMethodModule();
else
    fprintf('Barrier module not found.\n');
end