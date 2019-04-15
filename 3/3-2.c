#include <stdio.h>
#include <string.h>

typedef struct _Good {
    char name[10];
    int inprice;
    int sellprice;
    int stock;
    int sold;
    int profit;
} Good;

Good shop1[10] = {
        {"pen",  35, 56, 70, 25, 0},
        {"book", 12, 30, 25, 5,  0}
};
Good *shop1top = shop1 + 2;

void func1(Good *shop1begin, Good *shop1top);

void func2(Good *shop1begin, Good *shop1top);

void func3(Good *shop1begin, Good *shop1top);

void func4(Good *shop1begin, Good *shop1top);

void func5(Good *shop1begin, Good *shop1top);

const char *username = "zcr";
const char *password = "test";

void menu(int isAdmin) {
    int selection = 0/*, i = 0*/;
//    Good *shop1dstgood = NULL;
    while (1) {
        printf("1. Query Item\n");
        if (isAdmin) {
            printf("2. Modify Item\n");
            printf("3. Calculate Suggestion Rate\n");
            printf("4. Calculate Suggestion Rank\n");
            printf("5. Print All Goods\n");
        }
        printf("6. Exit\n");
        printf("Please input your selection: ");
        if (!scanf("%d", &selection)) {
            char buffer[50];
            scanf("%s", buffer);
            continue;
        }
        if (selection == 1) {
            func1(shop1, shop1top);
//            printf("Input item name: ");
//            scanf("%s", globbuf);
//            for (i = 0; shop1 + i < shop1top; i++) {
//                if (!strfcmp(shop1[i].name, globbuf)) {
//                    shop1dstgood = &(shop1[i]);
//                    break;
//                }
//            }
//            if (shop1 + i == shop1top) {
//                printf("Item not found, please input again\n");
//                continue;
//            }
//            printf("name\tdiscnt\tprice\tinNum\toutNum\t\n");
//            printf("%s,%s,%d,%d,%d\n", "shop1", shop1dstgood->name, shop1dstgood->sellprice, shop1dstgood->stock, shop1dstgood->sold);
        } else if (selection == 2) {
            if (!isAdmin) {
                printf("Permission Denied!\n");
                continue;
            }
            func2(shop1, shop1top);
        } else if (selection == 3) {
            if (!isAdmin) {
                printf("Permission Denied!\n");
                continue;
            }
            func3(shop1, shop1top);
        } else if (selection == 4) {
            if (!isAdmin) {
                printf("Permission Denied!\n");
                continue;
            }
            func4(shop1, shop1top);
        } else if (selection == 5) {
            if (!isAdmin) {
                printf("Permission Denied!\n");
                continue;
            }
            func5(shop1, shop1top);
        } else if (selection == 6) {
            break;
        } else {
            printf("Invalid selection!\n");
        }
    }
}

int main(void) {
    char input_username[20] = {0};
    char input_password[20] = {0};
    while (1) {
        printf("Please Input User Name:");
        scanf("%s", input_username);
        if (input_username[0] == 0) {
            menu(0);
        } else if (!strcmp("q", input_username)) {
            return 0;
        } else {
            printf("Please Input Password:");
            scanf("%s", input_password);
            if (!strcmp(input_username, username) && !strcmp(input_password, password)) {
                menu(1);
            } else {
                printf("Username and Password Mismatch!\n");
            }
        }
    }
    return 0;
}
