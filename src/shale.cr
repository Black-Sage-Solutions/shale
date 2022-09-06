require "./shale/*"

module Shale
  VERSION = "2022.9"
end

# FIXME, This causes an error with invalid memory access, not sure why exactly
# Some reason, no more error shows on exit with new file structure, not sure if this is doing anything now
# Nvm, adding a `finalize` method to the Display class bring back the error
# Maybe because at the exit flow, display.close is called explicitly and when the program exits with
#  GC.collect, display.finalize is called and tries the same thing, causing the invalid access exception
at_exit { GC.collect }

Shale.main
