class SpDonation < ActiveRecord::Base
# This may be backed by Peoplesoft/Oracle in the future.  
# For now, it is backed by a table that is synchronized with Oracle

  def self.get_balance(designation_number)
    return 0 unless designation_number
    -1 * (SpDonation.sum(:amount, 
      :conditions => ["designation_number = ?", designation_number]) || 0)
  end
  
  def self.get_balances(designation_numbers)
    return [] unless !designation_numbers.empty?
    sums = SpDonation.sum(:amount, 
      :conditions => ["designation_number in (?)", designation_numbers],
      :group => :designation_number)
    balances = Hash.new
    sums.each do |designation_number, amount|
      balances[designation_number] = -1 * amount
    end
    return balances
  end
  
  def self.update_from_peoplesoft
    SpDonation.delete_all
    # We don't want to pull in too many rows at once, since it can be over 100,000, so instead we loop through them.
#    startrow = 0
#    lastrow = 5000
#    while (rows = PsEmployee.connection.select_all("select * from (select a.*, rownum rnum from(select jrnl_ln_ref, monetary_amount from finprod.ps_jrnl_ln where (business_unit='CAMPS' or business_unit='KEYNT') and journal_id like 'CN%' and journal_date > to_date('01-Jan-#{SpApplication::YEAR}','DD-MON-YYYY') order by BUSINESS_UNIT, JOURNAL_ID, JOURNAL_DATE, UNPOST_SEQ, JOURNAL_LINE, LEDGER) a where rownum <= #{lastrow}) where rnum > #{startrow}"))
    rows = PsEmployee.connection.select_all("select jrnl_ln_ref, monetary_amount from finprod.ps_jrnl_ln where (business_unit='CAMPS' or business_unit='KEYNT') and journal_id like 'CN%' and journal_date > to_date('01-Jan-#{SpApplication::YEAR}','DD-MON-YYYY')")
    rows.each do |row|
      if row['jrnl_ln_ref'].strip.length > 0
        SpDonation.create(:designation_number => row['jrnl_ln_ref'], :amount => row['monetary_amount'])
      end
    end
    rows.size
#      start_row = lastrow
#      lastrow += 5000
#    end
  end
end
