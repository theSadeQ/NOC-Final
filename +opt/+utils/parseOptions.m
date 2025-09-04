function opts = parseOptions(userOpts, defaultOpts)
%PARSEOPTIONS  Merge user-supplied options with defaults.
%   opts = parseOptions(USEROPTS, DEFAULTOPTS) returns a struct whose
%   fields are given by DEFAULTOPTS, overridden by any matching fields
%   present in USEROPTS.  If USEROPTS is empty or missing, DEFAULTOPTS
%   are returned.  Fields not present in DEFAULTOPTS are ignored.
%
%   USEROPTS must be a struct.  If a field in USEROPTS has a value
%   whose class does not match the corresponding default, this
%   function throws an MException with identifier 'opt:utils:parseOptions'.

    if nargin < 1 || isempty(userOpts)
        opts = defaultOpts;
        return;
    end
    if ~isstruct(userOpts)
        errorStruct = struct('identifier','opt:utils:parseOptions', ...
                             'message','Options must be provided as a struct.');
        throw(MException(errorStruct.identifier, errorStruct.message));
    end
    opts = defaultOpts;
    userFields = fieldnames(userOpts);
    for k = 1:numel(userFields)
        fld = userFields{k};
        if isfield(defaultOpts, fld)
            defaultVal = defaultOpts.(fld);
            userVal = userOpts.(fld);
            % If both default and user values are numeric, accept; otherwise
            % check for class equality.
            if isnumeric(defaultVal) && isnumeric(userVal)
                opts.(fld) = userVal;
            elseif ischar(defaultVal) && ischar(userVal)
                opts.(fld) = userVal;
            elseif islogical(defaultVal) && islogical(userVal)
                opts.(fld) = userVal;
            elseif isa(defaultVal, class(userVal))
                opts.(fld) = userVal;
            else
                errorStruct = struct('identifier','opt:utils:parseOptions', ...
                                     'message',sprintf('Invalid type for field %s.',fld));
                throw(MException(errorStruct.identifier, errorStruct.message));
            end
        end
    end
end