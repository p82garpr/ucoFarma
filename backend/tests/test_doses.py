import requests

ENDPOINT = 'https://ucofarma.onrender.com'


def test_get_medicine_doses():
    # Paso 1: Autenticarse y obtener el token
    login_data = {
        "username": "test@example.com",
        "password": "test"
    }
    login_response = requests.post(ENDPOINT + "/auth/login", data=login_data)
    assert login_response.status_code == 200, f"Error en login: {login_response.text}"
    
    token = login_response.json().get("access_token")
    assert token, "No se obtuvo el token de acceso"
    
    # Paso 2: Obtener el user_id del usuario autenticado
    headers = {
        "Authorization": f"Bearer {token}"
    }
    me_response = requests.get(ENDPOINT + "/users/me", headers=headers)
    assert me_response.status_code == 200, f"Error al obtener datos del usuario: {me_response.text}"
    
    user_data = me_response.json()
    user_id = user_data.get("user_id")
    first_medicine_cn = user_data.get("medicines", [])[0].get("cn") if user_data.get("medicines") else None
    assert user_id, "No se encontró el user_id en la respuesta"
    assert first_medicine_cn, "No se encontró el CN del primer medicamento en la respuesta"
    print("User ID:", user_id)
    print("First medicine CN:", first_medicine_cn)
    
    # Paso 3: Obtener las dosis del medicamento
    doses_response = requests.get(
        ENDPOINT + f"/doses/{user_id}/{first_medicine_cn}",
        headers=headers
    )
    assert doses_response.status_code == 200, f"Error al obtener las dosis: {doses_response.text}"
    
    doses_data = doses_response.json()
    print("Doses del medicamento:", doses_data)
    
    # Validaciones adicionales (opcional)
    assert isinstance(doses_data, list), "La respuesta no es una lista de dosis"
    if doses_data:
        assert "frequency" in doses_data[0], "Falta el campo 'frequency' en una dosis"
        assert "quantity" in doses_data[0], "Falta el campo 'quantity' en una dosis"



def test_update_dose():
    # Paso 1: Autenticarse y obtener el token
    login_data = {
        "username": "test@example.com",
        "password": "test"
    }
    login_response = requests.post(ENDPOINT + "/auth/login", data=login_data)
    assert login_response.status_code == 200, f"Error en login: {login_response.text}"
    
    token = login_response.json().get("access_token")
    assert token, "No se obtuvo el token de acceso"
    
    # Paso 2: Obtener el user_id del usuario autenticado
    headers = {
        "Authorization": f"Bearer {token}"
    }
    me_response = requests.get(ENDPOINT + "/users/me", headers=headers)
    assert me_response.status_code == 200, f"Error al obtener datos del usuario: {me_response.text}"
    
    user_data = me_response.json()
    user_id = user_data.get("user_id")
    first_medicine_cn = user_data.get("medicines", [])[0].get("cn") if user_data.get("medicines") else None
    assert user_id, "No se encontró el user_id en la respuesta"
    assert first_medicine_cn, "No se encontró el CN del primer medicamento en la respuesta"
    print("User ID:", user_id)
    print("First medicine CN:", first_medicine_cn)
    
    # Paso 3: Actualizar la dosis del medicamento
    update_data = {
        "frequency": 8,  # Nueva frecuencia en horas
        "quantity": 2    # Nueva cantidad por dosis
    }
    update_response = requests.put(
        ENDPOINT + f"/doses/{user_id}/{first_medicine_cn}",
        headers=headers,
        params=update_data
    )
    assert update_response.status_code == 200, f"Error al actualizar la dosis: {update_response.text}"
    
    updated_dose = update_response.json()
    print("Dosis actualizada:", updated_dose)

