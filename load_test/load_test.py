#!/usr/bin/env python3
import yaml
import requests
import time
import sys
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
from threading import Lock

# 세션 재사용 (Keep-Alive)
session = requests.Session()
session.headers.update({'Connection': 'keep-alive'})

class ProgressTracker:
    def __init__(self, total):
        self.total = total
        self.completed = 0
        self.lock = Lock()
    
    def update(self):
        with self.lock:
            self.completed += 1
            percent = (self.completed / self.total) * 100
            bar_length = 50
            filled = int(bar_length * self.completed / self.total)
            bar = '█' * filled + '░' * (bar_length - filled)
            sys.stdout.write(f'\r진행: [{bar}] {percent:.1f}% ({self.completed}/{self.total})')
            sys.stdout.flush()

def load_config(file='requests.yaml'):
    with open(file) as f:
        data = yaml.safe_load(f)
        return data['config'], data['requests']

def make_request(req, token, results, progress):
    headers = {'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}
    start = time.time()
    try:
        kwargs = {'headers': headers, 'timeout': 10}
        if 'body' in req:
            kwargs['json'] = req['body']
        
        r = session.request(req['method'], req['url'], **kwargs)
        elapsed = time.time() - start
        results[req['url']]['success'] += 1
        results[req['url']]['times'].append(elapsed)
        results[req['url']]['status'][r.status_code] += 1
    except Exception as e:
        results[req['url']]['fail'] += 1
    finally:
        progress.update()

def print_results(results, total_time, config):
    print("\n\n" + "="*80)
    print("🔥 부하 테스트 결과")
    print("="*80)
    print(f"⚙️  Workers: {config['workers']} | Iterations: {config['iterations']}")
    print(f"⏱️  총 소요 시간: {total_time:.2f}초")
    
    total_requests = sum(d['success'] + d['fail'] for d in results.values())
    rps = total_requests / total_time if total_time > 0 else 0
    print(f"📊 초당 요청 수 (RPS): {rps:.2f}\n")
    
    for url, data in results.items():
        total = data['success'] + data['fail']
        times = sorted(data['times'])
        
        if times:
            avg_time = sum(times) / len(times)
            min_time = times[0]
            max_time = times[-1]
            median = times[len(times)//2]
            p50 = times[int(len(times)*0.50)]
            p90 = times[int(len(times)*0.90)]
            p95 = times[int(len(times)*0.95)]
            p99 = times[int(len(times)*0.99)]
        else:
            avg_time = min_time = max_time = median = p50 = p90 = p95 = p99 = 0
        
        print(f"🌐 URL: {url}")
        print(f"   총 요청: {total}")
        print(f"   ✅ 성공: {data['success']} ({data['success']/total*100:.1f}%)")
        print(f"   ❌ 실패: {data['fail']} ({data['fail']/total*100:.1f}%)")
        print(f"   ⚡ 응답시간:")
        print(f"      평균: {avg_time:.3f}초 | 최소: {min_time:.3f}초 | 최대: {max_time:.3f}초")
        print(f"      Median: {median:.3f}초 | p50: {p50:.3f}초")
        print(f"      p90: {p90:.3f}초 | p95: {p95:.3f}초 | p99: {p99:.3f}초")
        print(f"   📈 상태 코드: {dict(data['status'])}")
        print()

def run_load_test():
    config, reqs = load_config()
    token = config.get('token', '')
    
    if not token:
        print("⚠️  requests.yaml에 token을 입력해주세요")
        return
    
    results = defaultdict(lambda: {'success': 0, 'fail': 0, 'times': [], 'status': defaultdict(int)})
    total_requests = config['iterations'] * len(reqs)
    progress = ProgressTracker(total_requests)
    
    print(f"\n🚀 부하 테스트 시작...")
    print(f"⚙️  Workers: {config['workers']} | Iterations: {config['iterations']} | 총 요청: {total_requests}")
    print(f"💥 {config['workers']}개 스레드로 동시 요청 시작!\n")
    
    start_time = time.time()
    
    # 모든 요청을 한번에 제출 (진짜 동시 부하)
    with ThreadPoolExecutor(max_workers=config['workers']) as executor:
        futures = []
        for _ in range(config['iterations']):
            for req in reqs:
                future = executor.submit(make_request, req, token, results, progress)
                futures.append(future)
        
        # 모든 요청 완료 대기
        for future in futures:
            future.result()
    
    total_time = time.time() - start_time
    print_results(results, total_time, config)

if __name__ == '__main__':
    run_load_test()
