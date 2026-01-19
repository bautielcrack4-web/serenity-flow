import jwt
import time
import sys

def generate_client_secret(key_file, team_id, client_id, key_id):
    with open(key_file, 'r') as f:
        private_key = f.read()

    headers = {
        'kid': key_id,
        'alg': 'ES256'
    }

    payload = {
        'iss': team_id,
        'iat': int(time.time()),
        'exp': int(time.time()) + 15777000, # 6 months in seconds
        'aud': 'https://appleid.apple.com',
        'sub': client_id,
    }

    client_secret = jwt.encode(
        payload,
        private_key,
        algorithm='ES256',
        headers=headers
    )

    return client_secret

if __name__ == "__main__":
    print("-" * 50)
    print("Apple Client Secret Generator")
    print("-" * 50)
    
    # Configuration
    TEAM_ID = "KXVAN4J7F3" 
    # Using the Services ID as the subject for the JWT
    CLIENT_ID = "com.yuna.yoga.bauti.signin" 
    KEY_ID = "UZ3W6BA49U"
    KEY_FILE = "AuthKey_UZ3W6BA49U.p8"

    try:
        secret = generate_client_secret(KEY_FILE, TEAM_ID, CLIENT_ID, KEY_ID)
        print("\n✅ Generated Client Secret JWT (Copy this to Supabase):")
        print("-" * 20)
        print(secret)
        print("-" * 20)
    except FileNotFoundError:
        print(f"\n❌ Error: '{KEY_FILE}' not found.")
    except Exception as e:
        print(f"\n❌ Error: {e}")
