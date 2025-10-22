#!/bin/bash

# Week 4 Day 4 Lab 1: 프로젝트 복사 및 초기화
# 설명: lab_scripts의 cicd-lab을 현재 디렉토리로 복사
# 사용법: ./step1-setup-project.sh

set -e

echo "=== 프로젝트 초기화 시작 ==="

# 1. 기존 프로젝트 정리
echo "1/3 기존 프로젝트 정리 중..."
rm -rf cicd-lab

# 2. 프로젝트 복사
echo "2/3 프로젝트 복사 중..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -r "$SCRIPT_DIR/cicd-lab" ./cicd-lab

# 3. 결과 확인
echo "3/3 복사 완료 확인 중..."
cd cicd-lab
ls -la

echo ""
echo "=== 프로젝트 초기화 완료 ==="
echo ""
echo "프로젝트 위치: $PWD"
echo ""
echo "다음 단계: cd cicd-lab && ../step2-run-local.sh"
