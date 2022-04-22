//
// Autogenerated by Laurine - by Jiri Trecak ( http://jiritrecak.com, @jiritrecak )
// Do not change this file manually!
//


// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
// MARK: - Imports

import Foundation


// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
// MARK: - Localizations


public struct Localizations {


    public struct ListTransaction {

        /// Base translation: Expenses : %@ Incomes : %@ Total : %@
        public static func info(_ value1 : String, _ value2 : String, _ value3 : String) -> String {
            return String(format: NSLocalizedString("ListTransaction.info", comment: ""), value1, value2, value3)
        }


        public struct transaction {

            /// Base translation: 1 transaction
            public static var singular : String = NSLocalizedString("ListTransaction.transaction.singular", comment: "")

            /// Base translation: %d transaction
            public static func plural(_ value1 : Int) -> String {
                return String(format: NSLocalizedString("ListTransaction.transaction.plural", comment: ""), value1)
            }


            public struct selectionnee {

                /// Base translation: %d selected transactions 
                public static func plural(_ value1 : Int) -> String {
                    return String(format: NSLocalizedString("ListTransaction.transaction.selectionnee.plural", comment: ""), value1)
                }

                /// Base translation: 1 selected transaction 
                public static var singular : String = NSLocalizedString("ListTransaction.transaction.selectionnee.singular", comment: "")

            }
        }
    }

    public struct GroupeAccount {


        public struct RemoveAlert {

            /// Base translation: Cancel
            public static var Cancel : String = NSLocalizedString("GroupeAccount.RemoveAlert.Cancel", comment: "")

            /// Base translation: Supprimer cet élement
            public static var MessageText : String = NSLocalizedString("GroupeAccount.RemoveAlert.MessageText", comment: "")

            /// Base translation: Remove
            public static var Delete : String = NSLocalizedString("GroupeAccount.RemoveAlert.Delete", comment: "")

            /// Base translation: Are you sure you would like to delete this item ?
            public static var InformativeText : String = NSLocalizedString("GroupeAccount.RemoveAlert.InformativeText", comment: "")

        }
    }

    public struct SimplifiedImport {


        public struct Menu {

            /// Base translation: Statut
            public static var statut : String = NSLocalizedString("SimplifiedImport.Menu.statut", comment: "")

            /// Base translation: Category
            public static var category : String = NSLocalizedString("SimplifiedImport.Menu.category", comment: "")

            /// Base translation: Amount
            public static var amount : String = NSLocalizedString("SimplifiedImport.Menu.amount", comment: "")

            /// Base translation: Rubric
            public static var rubric : String = NSLocalizedString("SimplifiedImport.Menu.rubric", comment: "")

            /// Base translation: Date Transaction
            public static var dateTransaction : String = NSLocalizedString("SimplifiedImport.Menu.dateTransaction", comment: "")

            /// Base translation: Bank Statement
            public static var bankStatement : String = NSLocalizedString("SimplifiedImport.Menu.bankStatement", comment: "")

            /// Base translation: Payment method
            public static var paymentMethod : String = NSLocalizedString("SimplifiedImport.Menu.paymentMethod", comment: "")

            /// Base translation: Date Pointage
            public static var datePointage : String = NSLocalizedString("SimplifiedImport.Menu.datePointage", comment: "")

            /// Base translation: Comment
            public static var comment : String = NSLocalizedString("SimplifiedImport.Menu.comment", comment: "")

            /// Base translation: Ignore_Column
            public static var ignoreCol : String = NSLocalizedString("SimplifiedImport.Menu.ignoreCol", comment: "")

        }
    }

    public struct Transaction {

        /// Base translation: Transactions
        public static var operation : String = NSLocalizedString("Transaction.operation", comment: "")

        /// Base translation: Editing mode
        public static var ModeEdition : String = NSLocalizedString("Transaction.ModeEdition", comment: "")

        /// Base translation: Creative mode
        public static var ModeCreation : String = NSLocalizedString("Transaction.ModeCreation", comment: "")

        /// Base translation: Multiple value
        public static var MultipleValue : String = NSLocalizedString("Transaction.MultipleValue", comment: "")

        /// Base translation: (no transfert)
        public static var NoTransfert : String = NSLocalizedString("Transaction.NoTransfert", comment: "")

    }

    public struct RateConfigure {

        /// Base translation: Star Now!
        public static var likeButtonTitle : String = NSLocalizedString("RateConfigure.likeButtonTitle", comment: "")

        /// Base translation: Love Bergerac?
        public static var name : String = NSLocalizedString("RateConfigure.name", comment: "")

        /// Base translation: We look forward to your Star and Pull Request to make Bergerac better and better : ) ⭐️⭐️⭐️⭐️⭐️?
        public static var detailText : String = NSLocalizedString("RateConfigure.detailText", comment: "")

        /// Base translation: Perhaps later
        public static var ignoreButtonTitle : String = NSLocalizedString("RateConfigure.ignoreButtonTitle", comment: "")

    }

    public struct Graph {

        /// Base translation: Expense
        public static var Expense : String = NSLocalizedString("Graph.Expense", comment: "")

        /// Base translation: Income
        public static var Income : String = NSLocalizedString("Graph.Income", comment: "")

        /// Base translation: Rubric
        public static var Rubrique : String = NSLocalizedString("Graph.Rubrique", comment: "")

    }

    public struct Check {

        /// Base translation: Are you sure you would like to delete the check ?
        public static var InformativeText : String = NSLocalizedString("Check.InformativeText", comment: "")

        /// Base translation: Delete
        public static var Delete : String = NSLocalizedString("Check.Delete", comment: "")

        /// Base translation: Delete the check ?
        public static var MessageText : String = NSLocalizedString("Check.MessageText", comment: "")

    }

    public struct Statut {

        /// Base translation: Plannifie
        public static var Planifie : String = NSLocalizedString("Statut.Planifie", comment: "")

        /// Base translation: Engaged
        public static var Engaged : String = NSLocalizedString("Statut.Engaged", comment: "")

        /// Base translation: Executed
        public static var Realise : String = NSLocalizedString("Statut.Realise", comment: "")

    }

    public struct Chart {

        /// Base translation: No chart Data available.
        public static var No_chart_Data_Available : String = NSLocalizedString("Chart.No_chart_Data_Available.", comment: "")

    }

    public struct General {

        /// Base translation: Comment
        public static var Libelle : String = NSLocalizedString("General.Libelle", comment: "")

        /// Base translation: Scheduler
        public static var Scheduler : String = NSLocalizedString("General.Scheduler", comment: "")

        /// Base translation: Identity
        public static var Identity : String = NSLocalizedString("General.Identity", comment: "")

        /// Base translation: Rubric
        public static var Rubric : String = NSLocalizedString("General.Rubric", comment: "")

        /// Base translation: Transaction
        public static var Transaction : String = NSLocalizedString("General.Transaction", comment: "")

        /// Base translation: Statut
        public static var Statut : String = NSLocalizedString("General.Statut", comment: "")

        /// Base translation: Bank Statement
        public static var Bank_Statement : String = NSLocalizedString("General.Bank Statement", comment: "")

        /// Base translation: Date Transaction
        public static var Date_Operation : String = NSLocalizedString("General.Date Operation", comment: "")

        /// Base translation: Account
        public static var Account : String = NSLocalizedString("General.Account", comment: "")

        /// Base translation: List transactions
        public static var List_Transactions : String = NSLocalizedString("General.List Transactions", comment: "")

        /// Base translation: Cancel
        public static var Cancel : String = NSLocalizedString("General.Cancel", comment: "")

        /// Base translation: Balance
        public static var Solde : String = NSLocalizedString("General.Solde", comment: "")

        /// Base translation: Income
        public static var Income : String = NSLocalizedString("General.Income", comment: "")

        /// Base translation: Expenses
        public static var Expenses : String = NSLocalizedString("General.Expenses", comment: "")

        /// Base translation: Category
        public static var Category : String = NSLocalizedString("General.Category", comment: "")

        /// Base translation: Amount
        public static var Amount : String = NSLocalizedString("General.Amount", comment: "")

        /// Base translation: Mode Payment
        public static var Mode_Payment : String = NSLocalizedString("General.Mode Payment", comment: "")

        /// Base translation: Date Pointage
        public static var Date_Pointage : String = NSLocalizedString("General.Date Pointage", comment: "")


        public struct Account2 {

            /// Base translation: 1 account
            public static var Singular : String = NSLocalizedString("General.Account2.Singular", comment: "")

            /// Base translation: 0 account
            public static var Zero : String = NSLocalizedString("General.Account2.Zero", comment: "")

            /// Base translation: %d accounts
            public static func Plural(_ value1 : Int) -> String {
                return String(format: NSLocalizedString("General.Account2.Plural", comment: ""), value1)
            }

        }

        public struct BankAccount {

            /// Base translation: Bank accounts
            public static var Plural : String = NSLocalizedString("General.BankAccount.Plural", comment: "")

            /// Base translation: Bank account
            public static var Singular : String = NSLocalizedString("General.BankAccount.Singular", comment: "")

        }
    }

    public struct PaymentMethod {

        /// Base translation: Discount
        public static var Discount : String = NSLocalizedString("PaymentMethod.Discount", comment: "")

        /// Base translation: Bank Card
        public static var Bank_Card : String = NSLocalizedString("PaymentMethod.Bank_Card", comment: "")

        /// Base translation: Transfers
        public static var Transfers : String = NSLocalizedString("PaymentMethod.Transfers", comment: "")

        /// Base translation: Cash
        public static var Cash : String = NSLocalizedString("PaymentMethod.Cash", comment: "")

        /// Base translation: Retrait espéces
        public static var RetraitEspeces : String = NSLocalizedString("PaymentMethod.RetraitEspeces", comment: "")

        /// Base translation: Prelevement
        public static var Prelevement : String = NSLocalizedString("PaymentMethod.Prelevement", comment: "")

        /// Base translation: Check
        public static var Check : String = NSLocalizedString("PaymentMethod.Check", comment: "")

    }

    public struct Document {

        /// Base translation: Doe
        public static var IdName : String = NSLocalizedString("Document.IdName", comment: "")

        /// Base translation: Current account
        public static var Current_account : String = NSLocalizedString("Document.Current account", comment: "")

        /// Base translation: John
        public static var IdPrenom : String = NSLocalizedString("Document.IdPrenom", comment: "")

        /// Base translation: Bank card
        public static var Carte_de_crédit : String = NSLocalizedString("Document.Carte_de_crédit", comment: "")

        /// Base translation: Open Project
        public static var OpenProjectPanelMessage : String = NSLocalizedString("Document.OpenProjectPanelMessage", comment: "")

        /// Base translation: Bank account
        public static var Bank_Account : String = NSLocalizedString("Document.Bank_Account", comment: "")

        /// Base translation: Save
        public static var Save : String = NSLocalizedString("Document.Save", comment: "")

        /// Base translation: Cash account
        public static var Especes : String = NSLocalizedString("Document.Especes", comment: "")

    }

    public struct Mode {

        /// Base translation: Are you sure you would like to delete the item ?
        public static var InformativeText : String = NSLocalizedString("Mode.InformativeText", comment: "")

        /// Base translation: Delete
        public static var Delete : String = NSLocalizedString("Mode.Delete", comment: "")

        /// Base translation: Delete this element
        public static var MessageText : String = NSLocalizedString("Mode.MessageText", comment: "")

    }

    public struct Rubric {

        /// Base translation: Delete this element
        public static var MessageText : String = NSLocalizedString("Rubric.MessageText", comment: "")

        /// Base translation: Delete
        public static var Delete : String = NSLocalizedString("Rubric.Delete", comment: "")

        /// Base translation: L'élement supprimé ne pourra pas être restauré. Il sera remplacé dans les opérations par la valeur par défaut
        public static var InformativeText : String = NSLocalizedString("Rubric.InformativeText", comment: "")

    }

    public struct searchMenu {


        public struct title {

            /// Base translation: all
            public static var all : String = NSLocalizedString("searchMenu.title.all", comment: "")

            /// Base translation: Comment
            public static var comment : String = NSLocalizedString("searchMenu.title.comment", comment: "")

            /// Base translation: Rubric
            public static var rubric : String = NSLocalizedString("searchMenu.title.rubric", comment: "")

            /// Base translation: Category
            public static var category : String = NSLocalizedString("searchMenu.title.category", comment: "")

        }
    }
}