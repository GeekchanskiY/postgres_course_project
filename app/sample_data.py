
users = [
    {'username': 'user1', 'password': 'superP4S$W0RD', 'role': 'superuser'},
    {'username': 'user2', 'password': 'megaP4SS$0RD', 'role': 'user'},

    {'username': 'user3', 'password': 'superP4S$W0RD', 'role': 'superuser'},
    {'username': 'user4', 'password': 'superP4S$W0RD', 'role': 'superuser'},
    {'username': 'user5', 'password': 'superP4S$W0RD', 'role': 'superuser'},
    {'username': 'user6', 'password': 'superP4S$W0RD', 'role': 'superuser'},
    {'username': 'user7', 'password': 'superP4S$W0RD', 'role': 'superuser'},
    {'username': 'user8', 'password': 'superP4S$W0RD', 'role': 'superuser'},
    {'username': 'user9', 'password': 'superP4S$W0RD', 'role': 'superuser'},
    {'username': 'user10', 'password': 'superP4$SW0RD', 'role': 'superuser'},
    {'username': 'user11', 'password': 'superP4$SW0RD', 'role': 'superuser'},

    {'username': 'user21', 'password': 'megaP4S$$W0RD', 'role': 'user'},
    {'username': 'user22', 'password': 'megaP4S$W0RD', 'role': 'user'},
    {'username': 'user23', 'password': 'megaP4S$W0RD', 'role': 'user'},
    {'username': 'user24', 'password': 'megaP4SW$0RD', 'role': 'user'},
    {'username': 'user25', 'password': 'megaP4SW0$RD', 'role': 'user'},
    {'username': 'user26', 'password': 'megaP4SW0R$D', 'role': 'user'},
    {'username': 'user27', 'password': 'megaP4SW0$RD', 'role': 'user'},
    {'username': 'user28', 'password': 'megaP4SW$0RD', 'role': 'user'},
    {'username': 'user29', 'password': 'megaP4S$W0RD', 'role': 'user'},
    {'username': 'user30', 'password': 'megaP4SW0$RD', 'role': 'user'},
    {'username': 'user31', 'password': 'megaP4SW0$RD', 'role': 'user'},
]


cryptos = [
    {
        'name': 'Bitcoin',
        'symbol': 'BTC',
        'image': 'Bitcoin.png',
        'price': 26886.10,
        'volume': 10180726.908,
        'market_cap': 522151313.440,
        'transactions': 88001
    },
    {
        'name': 'Etherium',
        'symbol': 'ETH',
        'image': 'Etherium.png',
        'price': 26886.10,
        'volume': 10180726.908,
        'market_cap': 522151313.440,
        'transactions': 88001
    },
    {
        'name': 'Bitcoin2',
        'symbol': 'BTC2',
        'image': 'Bitcoin.png',
        'price': 26886.10,
        'volume': 10180726.908,
        'market_cap': 522151313.440,
        'transactions': 88001
    },
    {
        'name': 'Bitcoin3',
        'symbol': 'BTC3',
        'image': 'Bitcoin.png',
        'price': 26886.10,
        'volume': 10180726.908,
        'market_cap': 522151313.440,
        'transactions': 88001
    },
    {
        'name': 'Bitcoin4',
        'symbol': 'BTC4',
        'image': 'Bitcoin.png',
        'price': 26886.10,
        'volume': 10180726.908,
        'market_cap': 522151313.440,
        'transactions': 88001
    },

    {
        'name': 'Bitcoin5',
        'symbol': 'BTC5',
        'image': 'Bitcoin.png',
        'price': 26886.10,
        'volume': 10180726.908,
        'market_cap': 522151313.440,
        'transactions': 88001
    },
    {
        'name': 'Bitcoin6',
        'symbol': 'BTC6',
        'image': 'Bitcoin.png',
        'price': 26886.10,
        'volume': 10180726.908,
        'market_cap': 522151313.440,
        'transactions': 88001
    },
    {
        'name': 'Bitcoin7',
        'symbol': 'BTC7',
        'image': 'Bitcoin.png',
        'price': 26886.10,
        'volume': 10180726.908,
        'market_cap': 522151313.440,
        'transactions': 88001
    },
    {
        'name': 'Bitcoin8',
        'symbol': 'BTC8',
        'image': 'Bitcoin.png',
        'price': 26886.10,
        'volume': 10180726.908,
        'market_cap': 522151313.440,
        'transactions': 88001
    },
    {
        'name': 'Bitcoin9',
        'symbol': 'BTC9',
        'image': 'Bitcoin.png',
        'price': 26886.10,
        'volume': 10180726.908,
        'market_cap': 522151313.440,
        'transactions': 88001
    },
    {
        'name': 'Bitcoin10',
        'symbol': 'BTC10',
        'image': 'Bitcoin.png',
        'price': 26886.10,
        'volume': 10180726.908,
        'market_cap': 522151313.440,
        'transactions': 88001
    },
    {
        'name': 'Bitcoin11',
        'symbol': 'BTC11',
        'image': 'Bitcoin.png',
        'price': 26886.10,
        'volume': 10180726.908,
        'market_cap': 522151313.440,
        'transactions': 88001
    },
    {
        'name': 'Bitcoin12',
        'symbol': 'BTC12',
        'image': 'Bitcoin.png',
        'price': 26886.10,
        'volume': 10180726.908,
        'market_cap': 522151313.440,
        'transactions': 88001
    },


]


def get_sample_shots(start_price: float, amount: int) -> list:
    import random
    prices = []
    caps = []
    volumes = []
    transactions = []

    prev_price = start_price
    for i in range(amount):
        greater = random.choice([True, False])
        if greater:
            new_price = prev_price + random.uniform(i, 10000.3)
        else:
            new_price = prev_price - random.uniform(i, 10000.5)
            if new_price <= 0:
                new_price = random.uniform(5.3, 12000.21311)
        new_price = round(new_price, 5)
        old_price = new_price
        prices.append(old_price)

        caps.append(round(random.uniform(i, 10000.3), 5))
        volumes.append(round(random.uniform(i, 10000.3), 5))
        transactions.append(random.randint(i, 1000))

    return [prices, caps, volumes, transactions]


if __name__ == "__main__":
    print(get_sample_shots(1000, 15))
