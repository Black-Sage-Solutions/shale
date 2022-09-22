require "spec"
require "../../src/utils/png/decode"

describe "Trying png decode" do
  it "read" do
    png = PNG.decode "res/company-logo-leaf.png"
  end
end
