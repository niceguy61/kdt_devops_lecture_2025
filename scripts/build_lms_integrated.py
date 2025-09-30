#!/usr/bin/env python3
"""
KT Cloud TECH UP 2025 - Integrated LMS Build Script
Mermaid extraction -> PNG generation -> LMS markdown conversion
"""

import os
import re
import hashlib
import subprocess
import shutil
from pathlib import Path

class LMSBuilder:
    def __init__(self, base_dir="d:\\github\\kdt_devops_lecture_2025"):
        self.base_path = Path(base_dir).resolve()
        self.lms_path = self.base_path / "lms"
        self.github_base_url = "https://github.com/niceguy61/kdt_devops_lecture_2025/blob/main"
        
    def print_step(self, step, message):
        """Print step information"""
        print(f"\n{'='*60}")
        print(f"Step {step}: {message}")
        print('='*60)
    
    def get_mermaid_hash(self, mermaid_code):
        """Generate hash for Mermaid code"""
        hash_obj = hashlib.md5(mermaid_code.strip().encode())
        return hash_obj.hexdigest()[:8]
    
    def extract_mermaid_from_file(self, file_path):
        """Extract Mermaid charts from file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            pattern = r'```mermaid\n(.*?)\n```'
            matches = re.findall(pattern, content, re.DOTALL)
            return matches
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
            return []
    
    def create_mermaid_file(self, mermaid_code, output_dir, file_prefix, index):
        """Save Mermaid code to .mmd file"""
        hash_str = self.get_mermaid_hash(mermaid_code)
        filename = f"{file_prefix}_{index:02d}_{hash_str}.mmd"
        filepath = output_dir / filename
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(mermaid_code.strip())
        
        return filepath
    
    def step1_extract_mermaid(self):
        """Step 1: Extract Mermaid charts"""
        self.print_step(1, "Extracting Mermaid charts")
        
        total_extracted = 0
        
        # Process each week
        for week_dir in self.base_path.glob("theory/week_*"):
            if not week_dir.is_dir():
                continue
                
            week_name = week_dir.name
            print(f"\nProcessing: {week_name}")
            
            # Create images directory
            images_dir = week_dir / "images"
            images_dir.mkdir(exist_ok=True)
            
            week_count = 0
            
            # Process all .md files in week directory
            for md_file in week_dir.rglob("*.md"):
                if "images" in str(md_file):
                    continue
                    
                relative_path = md_file.relative_to(week_dir)
                file_prefix = str(relative_path).replace("/", "_").replace("\\", "_").replace(".md", "")
                
                mermaid_charts = self.extract_mermaid_from_file(md_file)
                
                for i, chart in enumerate(mermaid_charts):
                    week_count += 1
                    total_extracted += 1
                    mermaid_file = self.create_mermaid_file(chart, images_dir, file_prefix, i + 1)
                    print(f"  Created: {mermaid_file.name}")
            
            print(f"{week_name}: {week_count} charts extracted")
        
        # Process root README.md
        root_readme = self.base_path / "README.md"
        if root_readme.exists():
            print(f"\nProcessing: Root README.md")
            
            root_images_dir = self.base_path / "images"
            root_images_dir.mkdir(exist_ok=True)
            
            mermaid_charts = self.extract_mermaid_from_file(root_readme)
            
            for i, chart in enumerate(mermaid_charts):
                total_extracted += 1
                mermaid_file = self.create_mermaid_file(chart, root_images_dir, "README", i + 1)
                print(f"  Created: {mermaid_file.name}")
            
            print(f"Root README: {len(mermaid_charts)} charts extracted")
        
        print(f"\nTotal {total_extracted} Mermaid charts extracted")
        return total_extracted
    
    def step2_convert_to_png(self):
        """Step 2: Convert Mermaid files to PNG"""
        self.print_step(2, "Converting Mermaid to PNG")
        
        # Check Mermaid CLI installation
        try:
            result = subprocess.run(['mmdc', '--version'], capture_output=True, check=True, shell=True)
            print("Mermaid CLI found")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("ERROR: Mermaid CLI not installed")
            print("Install with: npm install -g @mermaid-js/mermaid-cli")
            return False
        
        total_converted = 0
        
        # Process each week's images folder
        for week_dir in self.base_path.glob("theory/week_*"):
            images_dir = week_dir / "images"
            if not images_dir.exists():
                continue
                
            print(f"\nConverting: {images_dir.relative_to(self.base_path)}")
            
            for mmd_file in images_dir.glob("*.mmd"):
                png_file = mmd_file.with_suffix('.png')
                
                if png_file.exists():
                    print(f"  -> {mmd_file.name} (already exists)")
                    continue
                
                try:
                    cmd = [
                        'mmdc',
                        '-i', str(mmd_file),
                        '-o', str(png_file),
                        '-t', 'neutral',
                        '-b', 'white',
                        '--width', '1200',
                        '--height', '800'
                    ]
                    
                    result = subprocess.run(cmd, capture_output=True, text=True, shell=True)
                    
                    if result.returncode == 0:
                        print(f"  OK {mmd_file.name} -> {png_file.name}")
                        total_converted += 1
                    else:
                        print(f"  ERROR: {mmd_file.name}")
                        if result.stderr:
                            print(f"    {result.stderr}")
                            
                except Exception as e:
                    print(f"  ERROR: {mmd_file.name} - {e}")
        
        # Process root images folder
        root_images_dir = self.base_path / "images"
        if root_images_dir.exists():
            print(f"\nConverting: {root_images_dir.relative_to(self.base_path)}")
            
            for mmd_file in root_images_dir.glob("*.mmd"):
                png_file = mmd_file.with_suffix('.png')
                
                if png_file.exists():
                    print(f"  -> {mmd_file.name} (already exists)")
                    continue
                
                try:
                    cmd = [
                        'mmdc',
                        '-i', str(mmd_file),
                        '-o', str(png_file),
                        '-t', 'neutral',
                        '-b', 'white',
                        '--width', '1200',
                        '--height', '800'
                    ]
                    
                    result = subprocess.run(cmd, capture_output=True, text=True, shell=True)
                    
                    if result.returncode == 0:
                        print(f"  OK {mmd_file.name} -> {png_file.name}")
                        total_converted += 1
                    else:
                        print(f"  ERROR: {mmd_file.name}")
                        
                except Exception as e:
                    print(f"  ERROR: {mmd_file.name} - {e}")
        
        print(f"\nTotal {total_converted} PNG files generated")
        return True
    
    def convert_md_for_lms(self, file_path, output_path):
        """Convert MD file Mermaid charts to GitHub image links"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Calculate image folder path
            relative_path = file_path.relative_to(self.base_path)
            
            if str(relative_path).startswith("theory\\week_"):
                week_match = re.match(r"theory\\(week_\d+)", str(relative_path))
                if week_match:
                    week_name = week_match.group(1)
                    images_path = f"theory/{week_name}/images"
                else:
                    images_path = "images"
            else:
                images_path = "images"
            
            # Generate file prefix
            if "day" in str(relative_path) and ("session" in str(relative_path) or "lab" in str(relative_path)):
                parts = str(relative_path).split("\\")
                if len(parts) >= 3:
                    day_part = parts[-2]  # day1, day2 etc
                    session_file = parts[-1].replace(".md", "")  # session_1, lab_1 etc
                    file_prefix = f"{day_part}_{session_file}"
                else:
                    file_prefix = str(relative_path).replace("\\", "_").replace("/", "_").replace(".md", "")
            else:
                file_prefix = str(relative_path).replace("\\", "_").replace("/", "_").replace(".md", "")
            
            # Find and replace Mermaid blocks
            def replace_mermaid(match):
                mermaid_code = match.group(1)
                hash_str = self.get_mermaid_hash(mermaid_code)
                
                # Generate PNG filename
                mermaid_index = len(re.findall(r'```mermaid', content[:match.start()])) + 1
                png_filename = f"{file_prefix}_{mermaid_index:02d}_{hash_str}.png"
                
                # Generate GitHub image URL
                image_url = f"{self.github_base_url}/{images_path}/{png_filename}?raw=true"
                
                return f"![Mermaid Chart]({image_url})"
            
            # Replace Mermaid code blocks with image links
            pattern = r'```mermaid\n(.*?)\n```'
            converted_content = re.sub(pattern, replace_mermaid, content, flags=re.DOTALL)
            
            # Save output file
            output_path.parent.mkdir(parents=True, exist_ok=True)
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(converted_content)
            
            return True
            
        except Exception as e:
            print(f"Error converting {file_path}: {e}")
            return False
    
    def step3_convert_for_lms(self):
        """Step 3: Convert markdown for LMS"""
        self.print_step(3, "Converting markdown for LMS")
        
        # Remove existing LMS folder and recreate
        if self.lms_path.exists():
            shutil.rmtree(self.lms_path)
            print(f"Removed existing LMS folder: {self.lms_path}")
        
        converted_count = 0
        
        # Find and convert all .md files
        for md_file in self.base_path.rglob("*.md"):
            # Exclude lms and scripts folders
            if "lms" in str(md_file) or "scripts" in str(md_file):
                continue
                
            # Calculate relative path
            relative_path = md_file.relative_to(self.base_path)
            output_path = self.lms_path / relative_path
            
            if self.convert_md_for_lms(md_file, output_path):
                converted_count += 1
                print(f"Converted: {relative_path}")
        
        print(f"\nTotal {converted_count} files converted!")
        print(f"LMS folder: {self.lms_path}")
        return converted_count
    
    def step4_copy_additional_files(self):
        """Step 4: Copy additional files"""
        self.print_step(4, "Copying additional files")
        
        # Copy .amazonq folder
        amazonq_src = self.base_path / ".amazonq"
        amazonq_dst = self.lms_path / ".amazonq"
        
        if amazonq_src.exists():
            shutil.copytree(amazonq_src, amazonq_dst, dirs_exist_ok=True)
            print(f"OK .amazonq folder copied")
        
        # Copy agents folder
        agents_src = self.base_path / "agents"
        agents_dst = self.lms_path / "agents"
        
        if agents_src.exists():
            shutil.copytree(agents_src, agents_dst, dirs_exist_ok=True)
            print(f"OK agents folder copied")
        
        # Copy analysis folder
        analysis_src = self.base_path / "analysis"
        analysis_dst = self.lms_path / "analysis"
        
        if analysis_src.exists():
            shutil.copytree(analysis_src, analysis_dst, dirs_exist_ok=True)
            print(f"OK analysis folder copied")
        
        # Copy other important files
        important_files = ["GLOSSARY.md", "LEVEL_TEST.md"]
        
        for filename in important_files:
            src_file = self.base_path / filename
            dst_file = self.lms_path / filename
            
            if src_file.exists():
                shutil.copy2(src_file, dst_file)
                print(f"OK {filename} copied")
        
        print("\nAdditional files copy complete")
    
    def build_all(self):
        """Execute full build process"""
        print("KT Cloud TECH UP 2025 - LMS Build Started")
        print(f"Base Directory: {self.base_path}")
        print(f"LMS Directory: {self.lms_path}")
        print(f"GitHub URL: {self.github_base_url}")
        
        try:
            # Step 1: Extract Mermaid
            extracted = self.step1_extract_mermaid()
            
            # Step 2: Convert to PNG
            if not self.step2_convert_to_png():
                print("ERROR: PNG conversion failed - Mermaid CLI required")
                return False
            
            # Step 3: Convert for LMS
            converted = self.step3_convert_for_lms()
            
            # Step 4: Copy additional files
            self.step4_copy_additional_files()
            
            # Completion message
            self.print_step("COMPLETE", "LMS Build Success!")
            print(f"Extracted Mermaid charts: {extracted}")
            print(f"Converted markdown files: {converted}")
            print(f"LMS output folder: {self.lms_path}")
            print(f"GitHub URL: {self.github_base_url}")
            print("\nNotes:")
            print("   - Check GitHub URL matches your repository")
            print("   - Verify PNG files are uploaded to GitHub")
            print("   - Test image display in LMS")
            
            return True
            
        except Exception as e:
            print(f"ERROR: Build failed: {e}")
            return False

def main():
    """Main function"""
    builder = LMSBuilder()
    success = builder.build_all()
    
    if success:
        print("\nBuild completed successfully!")
    else:
        print("\nBuild failed with errors.")
    
    return success

if __name__ == "__main__":
    main()