#include <stdio.h>
#include <string.h>

typedef struct Item {
    char name[10];
    unsigned char discount;
    short inPrice;
    short price;
    short inNum;
    short outNum;
    short suggestion;
} Item;

Item shop[30] = {
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"temp", 8,  15, 30,  30, 2,  0},
        {"pen",  10, 35, 56,  70, 25, 0},
        {"book", 9,  12, 30,  25, 5,  0},
        {"bag",  9,  40, 100, 45, 5,  0},
};

void func2(void);

void func3(void);

void func4(void);

void func5(void);

void calc(Item *);

const char *username = "zcr";
const char *password = "test";

void func1(void) {
    while (1) {
        char name[20];
        int i = 0;
        printf("Input item name: ");
        scanf("%s", name);
        for (; i < 30; i++) {
            if (!strcmp(shop[i].name, name)) {
                Item item = shop[i];
                calc(&(shop[i]));
                printf("name\tdiscnt\tprice\tinNum\toutNum\tsuggestion\n");
                printf("%s\t%d\t%d\t%d\t%d\t%d\n", item.name, item.discount, item.price, item.inNum, item.outNum, item.suggestion);
                return;
            }
        }
        printf("Item not found, please input again\n");
    }
}

void menu(int isAdmin) {
    int selection = 0;
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
            printf("Error: invalid selection!\n");
            continue;
        }
        if (selection == 1) {
            func1();
        } else if (selection == 2) {
            if (!isAdmin) {
                printf("Error: invalid selection!\n");
                continue;
            }
            func2();
        } else if (selection == 3) {
            if (!isAdmin) {
                printf("Error: invalid selection!\n");
                continue;
            }
            func3();
        } else if (selection == 4) {
            if (!isAdmin) {
                printf("Error: invalid selection!\n");
                continue;
            }
            func4();
        } else if (selection == 5) {
            if (!isAdmin) {
                printf("Error: invalid selection!\n");
                continue;
            }
            func5();
        } else if (selection == 6) {
            break;
        } else {
            printf("Error: invalid selection!\n");
        }
    }
}

void print(char *string) {
    printf(string);
}

int main(void) {
    char input_username[20];
    char input_password[20];
    while (1) {
        printf("Please Input User Name:");
        scanf("%s", input_username);
        if (!strcmp("guest", input_username)) {
            menu(0);
        } else if (!strcmp("q", input_username)) {
            return 0;
        } else {
            printf("Please Input Password:");
            scanf("%s", input_password);
            if (!strcmp(input_username, username) && !strcmp(input_password, password)) {
                menu(1);
            } else {
                printf("Login failed, please input again.\n");
            }
        }
    }
}
