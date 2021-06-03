//DBS311 NCC Group Assignment 2
//Name: Mia Le              Student Number: 131101198
//Name: Reza Poursafa       Student Number: 140640194
//Name: Chiao-Ya Chang      Student Number: 130402191


#include <iostream>
#include <string>
#include <occi.h>
#include <cctype>

using oracle::occi::Environment;
using oracle::occi::Connection;

using namespace oracle::occi;
using namespace std;

int mainMenu();
int customerLogin(int customerId, Connection* cn);
int addToCart(Connection* conn, struct ShoppingCart cart[]);
double findProduct(Connection* conn, int product_id); 
void displayProducts(struct ShoppingCart cart[], int productCount);
int checkout(Connection* conn, struct ShoppingCart cart[], int customerId, int productCount);

struct ShoppingCart {
	int product_id;
	double price;
	int quantity;
};

int mainMenu() {
	int option = 0;
	do {
		std::cout << "******************** Main Menu ********************\n"
			<< "1)\tLogin" << endl
			<< "0)\tExit" << endl;

		if (option != 0 && option != 1) {
			std::cout << "You entered a wrong value. Enter an option (0-1): ";
		}
        else {
            std::cout << "Enter an option (0-1): ";
        }

        while (!(std::cin >> option)) {
            std::cout << " A number must be entered: ";
            cin.clear();
            cin.ignore(9999, '\n');
        }
	} while (option != 0 && option != 1);

	return option;
}

int customerLogin(int customerId , Connection* cn) {
	Statement* s = cn->createStatement();
	
	s->setSQL("BEGIN find_customer(:1 , :2); END;");

	int quantity;
	s->setInt(1, customerId);
	s->registerOutParam(2, Type::OCCIINT, sizeof(quantity));
	s->executeUpdate();
	quantity = s->getInt(2);
	cn->terminateStatement(s);

	if (quantity == 0){
        std::cout << "The customer does not exist." << endl; 
	}
	return quantity;

}

double findProduct(Connection* conn, int product_id) {
    double price;
    Statement* stmt = conn->createStatement();
    stmt->setSQL("BEGIN find_product(:1 , :2); END;");
    stmt->setInt(1, product_id);
    stmt->registerOutParam(2, Type::OCCIDOUBLE, sizeof(price));
    stmt->executeUpdate();
    price = stmt->getDouble(2);
    conn->terminateStatement(stmt);

    return price > 0 ? price : 0;
    
}

int addToCart(Connection* conn, struct ShoppingCart cart[]) {
	std::cout << "-------------- Add Products to Cart --------------" << endl;

    for (int i = 0; i < 10; ++i) {
        
        int productID;
        int quantity;
        ShoppingCart item;
        
        int op = 0;
        do {
            std::cout << "Enter the product ID: ";
            std::cin >> productID;
            
            if ( findProduct(conn, productID) == 0) { //cannot find
                std::cout << "The product does not exists. Try again..." << endl;
            }
        } while (findProduct(conn, productID) == 0);
            
            
        std::cout << "Product Price: " << findProduct(conn, productID) << endl;
            std::cout << "Enter the product Quantity: ";
            std::cin >> quantity;


            item.product_id = productID;
            item.price = findProduct(conn, productID);
            item.quantity = quantity;
			//add to cart
            cart[i] = item;
			 
			//if the number of product is 10, return i+1
			if ( i == 9){
                return i + 1;
			}
            else{
				std::cout << "Enter 1 to add more products or 0 to checkout: ";
                std::cin >> op;
				if(op == 0){
                    return i + 1; //no of products
				}
			}			
        
    }
}



void displayProducts(struct ShoppingCart cart[], int productCount){
	double total = 0.0;
	if(productCount > 0){        
        std::cout << "------- Ordered Products ---------\n";
		for (int i = 0; i< productCount;i++){
			std::cout << "---Item " << i + 1 << endl;
			std::cout << "Product ID: " << cart[i].product_id << endl;
			std::cout << "Price: " << cart[i].price << endl;
			std::cout << "Quantity: " << cart[i].quantity << endl;
			total += cart[i].price * cart[i].quantity;
		}
        std::cout << "----------------------------------" << endl;
        std::cout << "Total: " << total << endl;
	}
    else {
        std::cout << "No product in Cart " << endl;
	}

}

int checkout(Connection* conn, struct ShoppingCart cart[], int customerId, int productCount) {

    char userInput;
    int exit = 1;
        do{
            std::cout << "Would you like to checkout? (Y/y or N/n) ";
            std::cin >> userInput;

            if(userInput != 'y' && userInput != 'Y' && userInput != 'n' && userInput != 'N'){
                std::cout << "Wrong input. Try again..." << endl;
			}
        } while (userInput != 'y' && userInput != 'Y' && userInput != 'n' && userInput != 'N');

    if(userInput == 'n' || userInput == 'N'){
        std::cout << "The order is cancelled." << endl;
        exit = 0;
	}
    else if (userInput == 'y' || userInput == 'Y'){
        int o_id;
        Statement* stmt = conn->createStatement();
        stmt->setSQL("BEGIN add_order(:1 , :2); END;");
        stmt->setInt(1, customerId);
        stmt->registerOutParam(2, Type::OCCIINT, sizeof(o_id));
        stmt->executeUpdate();
        o_id = stmt->getInt(2);

        for (int i = 0; i < productCount; i++) {

            stmt->setSQL("BEGIN add_order_item(:1 , :2 , :3 , :4 , :5); END;");
            stmt->setInt(1, o_id);
            stmt->setInt(2, i + 1);
            stmt->setInt(3, cart[i].product_id);
            stmt->setInt(4, cart[i].quantity);
            stmt->setDouble(5, cart[i].price);
            stmt->executeUpdate();
        }

        std::cout << "The order is successfully completed." << endl;
        conn->terminateStatement(stmt);

	}

    return exit;
}


int main(void)
{

    /* OCCI Variables */
   Environment* env = nullptr;
   Connection* conn = nullptr;
   Statement* stmt = nullptr;
   

   /* Used Variables */
   
   string user = "dbs311_203c29";
   string pass = "15695194";
   string constr = "myoracle12c.senecacollege.ca:1521/oracle12c";

   try{
	env = Environment::createEnvironment(Environment::DEFAULT);
		conn = env->createConnection(user, pass, constr);
		

   int cusId = 0;


   
   int option = 0 ;
   int exist;
   do {
	   option = mainMenu();
      
       if (option == 1) {
           cout << "Please enter customer Id: ";
           cin >> cusId;



           exist = customerLogin(cusId, conn);
           if (exist != 0) {

               
                //create shopping cart
               ShoppingCart cart[10];
               //add to  cart
               int numberOfProducts = addToCart(conn, cart);
               displayProducts(cart, numberOfProducts);
               checkout(conn, cart, cusId, numberOfProducts);

           }

       }
        
   } while (option != 0);
  
       std::cout << "Good bye!..." << endl;
   
		
		env->terminateConnection(conn);
		Environment::terminateEnvironment(env);
    }

    catch (SQLException& sqlExcp) {
        std::cout << "error";
        std::cout << sqlExcp.getErrorCode() << ": " << sqlExcp.getMessage();
    }


    return 0;
}
