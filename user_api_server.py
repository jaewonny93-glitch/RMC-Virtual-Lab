"""
RMC Virtual Lab - 사용자 관리 API 서버
포트 8080에서 실행. 사용자 신청/승인/거절 데이터를 서버 파일에 저장.
모든 브라우저/기기가 동일 데이터를 공유.
"""
import json
import os
from flask import Flask, request, jsonify

app = Flask(__name__)
DATA_FILE = os.path.join(os.path.dirname(__file__), 'users_data.json')

def _load():
    if not os.path.exists(DATA_FILE):
        return []
    with open(DATA_FILE, 'r', encoding='utf-8') as f:
        try:
            return json.load(f)
        except Exception:
            return []

def _save(users):
    with open(DATA_FILE, 'w', encoding='utf-8') as f:
        json.dump(users, f, ensure_ascii=False, indent=2)

def _cors(resp):
    resp.headers['Access-Control-Allow-Origin'] = '*'
    resp.headers['Access-Control-Allow-Methods'] = 'GET,POST,PUT,OPTIONS'
    resp.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    return resp

@app.after_request
def after(resp):
    return _cors(resp)

@app.route('/users', methods=['OPTIONS'])
@app.route('/users/<uid>', methods=['OPTIONS'])
def options_handler(**kwargs):
    return _cors(jsonify({}))

# ── 전체 사용자 목록 조회 ──────────────────────────────
@app.route('/users', methods=['GET'])
def get_users():
    return jsonify(_load())

# ── 사용자 등록 (신청) ────────────────────────────────
@app.route('/users', methods=['POST'])
def add_user():
    users = _load()
    data = request.get_json()
    # 중복 체크 (이름+소속)
    existing = next((u for u in users
                     if u.get('name','').strip() == data.get('name','').strip()
                     and u.get('affiliation','').strip() == data.get('affiliation','').strip()), None)
    if existing:
        return jsonify({'id': existing['id'], 'isExisting': True, 'user': existing})
    users.append(data)
    _save(users)
    return jsonify({'id': data['id'], 'isExisting': False, 'user': data})

# ── 단일 사용자 조회 (상태 확인) ──────────────────────
@app.route('/users/<uid>', methods=['GET'])
def get_user(uid):
    users = _load()
    user = next((u for u in users if u.get('id') == uid), None)
    if user is None:
        return jsonify(None), 404
    return jsonify(user)

# ── 사용자 상태 업데이트 (승인/거절/권한취소) ───────────
@app.route('/users/<uid>', methods=['PUT'])
def update_user(uid):
    users = _load()
    data = request.get_json()
    idx = next((i for i, u in enumerate(users) if u.get('id') == uid), None)
    if idx is None:
        return jsonify({'error': 'not found'}), 404
    users[idx].update(data)
    _save(users)
    return jsonify(users[idx])

if __name__ == '__main__':
    print("RMC User API Server running on port 8080")
    app.run(host='0.0.0.0', port=8080, debug=False)
