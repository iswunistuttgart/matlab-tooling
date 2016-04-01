function varargout = semilogxy(varargin)

hPlot = plot3(varargin{:});

set(gca, 'XScale', 'log', 'YScale', 'log');

if nargout > 0
    varargout{1} = hPlot;
end

end