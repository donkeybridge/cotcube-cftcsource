## 0.1.0 (October 27, 2020)
  - Bitangent::SlopeTree: added color support to #add
  - Bitangent::SlopeTree: The main dicts have been reworked to utilize the new slope attributes instead of providing Hashes
  - Bitangent::Slope added attributes :color and :age for use in SlopeTree
  - changed names: SlopeTree become SlopeShape, SlopeManager becomes SlopeTree
  - Bitangent::SlopeManager added
  - Bitangent::SlopeTree: reworkged #recurse and according parameters
  - Bitangent::Slope: Commented parameters
  - SPEC: Few more tests (Bitangent::Sloep.predict)
  - Bitangent::Sample added second sample set (NGX-2020-10-21) as ,sample_2
  - commit before bath tub
  - added lib/bitangent.rb, the file that is autoloaded and itself loads subsequent dependencies
  - Added Array#one_to_one, which executes a block on each pair of neighbours and returns resulting new array
  - Added module Bitangent::Helpers, currently including .deg2rad, .rad2deg, .shear_to_rad(:base) and .shear_to_deg(:base)
  - Bitangent::Sample.sample provides NGX at 2020-10-16
  - Gemspec: Added 'activesupport', moved 'rake' to bitangent.gemspec'
  - Initializing ....

