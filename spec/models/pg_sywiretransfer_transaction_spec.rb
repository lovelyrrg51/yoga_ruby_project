require 'rails_helper'

RSpec.describe PgSywiretransferTransaction, type: :model do

  it { should belong_to(:pg_sywiretransfer_merchant)}

end
