
require'CSV'
require'pry'

#############################################################
#
# Bank transaction object
#
#############################################################

class BankTransaction
	attr_reader	 :date,	 :amount,	 :description,	:account

	def initialize(transactions = {})
		@date = transactions["Date"]
		@amount = transactions["Amount"].to_f
		@description = transactions["Description"]
		@account = transactions["Account"]
	end

	def credit?
		@amount > 0
	end

	def debit?
		@amount < 0
	end

	# def type
	# 	if credit?

	def summary
		if credit?
		"#{@date} - \tCREDIT\t - #{format_currency(@amount.abs)}\t - #{@description} "
		else
		"#{@date} -  \tDEBIT\t - #{format_currency(@amount.abs)}\t - #{@description} "
		end
	end
end

#############################################################
#
#  Bank Account Object
#
#############################################################


class BankAccount
	attr_accessor :transactions
	attr_reader :begin_bal, :name

	def initialize(begin_balance, name)
		@begin_bal = begin_balance.to_f
		@name = name
		@transactions = []
	end

	def add_trans(transaction)
		@transactions << transaction
	end

	def summary
		@transactions.map do |bank_transaction_object|
			bank_transaction_object.summary
		end
	end

	def end_balance
		@transactions.inject(@begin_bal) { |sum, trans| sum + trans.amount }

	end
end

#############################################################
#
#  Methods
#
#############################################################

def grab_first_word(string)
	string.split(" ").first
end

def format_currency(currency)
	sprintf('$%.2f', currency)
end

#############################################################
#
#  Create a Hash of all Accounts included in CSV file as
#  bank acount objects
#  accounts {"Business" => BankAccountObject1,
#  					  "Purchasing" => BankAccountObject2}
#
#############################################################

accounts = {}

CSV.foreach('balances.csv', headers: true) do |row|

	short_acct_name = grab_first_word(row["Account"])
	accounts[short_acct_name] = BankAccount.new(row["Balance"], row["Account"])

end

#############################################################
#
#  Bring CSV data into Brank Transactions Objects. For example
#  tr1 = BankTransaction.new({"Date"=>"10/2/2013",
# 														"Amount"=>"-29.99",
#   													"Description"=>"Amazon.com",
#    													"Account"=>"Business Checking"})
#
#############################################################


CSV.foreach('bank_data.csv', headers: true ) do |trans|
	 trans = trans.to_hash
	 name_from_transaction = grab_first_word(trans["Account"])
	 existing_account = accounts[name_from_transaction]


	 unless existing_account
 		existing_account = BankAccount.new(0, name_from_transaction)
 		accounts[name_from_transaction] = existing_account
 		binding.pry
	 end

	 if	existing_account.name == trans["Account"]
	 		existing_account.add_trans(BankTransaction.new(trans.to_hash))
	 end
end

#############################################################
#
# Prints account hashes to screen for business and purchasing
#
#############################################################

accounts.each do |k, v|
	puts " " , "==== #{v.name} ===="
	puts "Starting Balance: #{format_currency(v.begin_bal)}"
	puts "Ending Balance: #{format_currency(v.end_balance)}"
	puts v.summary
end

