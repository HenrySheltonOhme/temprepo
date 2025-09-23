"""
Demonstration of the fix for the anomaly detection engine issue.

Error: AttributeError: 'numpy.ndarray' object has no attribute 'fillna'
Location: anomaly_engine.py line 547 in generate_full_raw_table function

The issue occurs when trying to call .fillna(0) on a numpy array instead of a pandas DataFrame.
"""

import numpy as np
import pandas as pd


def demonstrate_problem_and_solution():
    """Demonstrates the problem and shows multiple solution approaches."""
    
    print("=== Anomaly Detection Engine Fix Demo ===\n")
    
    # Simulate the problematic scenario
    print("1. Simulating the problematic code:")
    
    # Create a numpy array with NaN values (similar to what might be happening)
    problematic_array = np.array([1.0, 2.0, np.nan, 4.0, np.nan, 6.0])
    print(f"Numpy array with NaN values: {problematic_array}")
    
    # This would cause the error:
    try:
        result = problematic_array.fillna(0)  # This will fail
    except AttributeError as e:
        print(f"❌ Error (as expected): {e}")
    
    print("\n2. Solutions for the problem:")
    
    # Solution 1: Use numpy's nan_to_num
    print("\nSolution 1: Using np.nan_to_num()")
    fixed_array_1 = np.nan_to_num(problematic_array, nan=0.0)
    print(f"Fixed array: {fixed_array_1}")
    
    # Solution 2: Convert to DataFrame first, then use fillna
    print("\nSolution 2: Convert to DataFrame first")
    df = pd.DataFrame(problematic_array, columns=['values'])
    fixed_df = df.fillna(0)
    print(f"Fixed DataFrame:\n{fixed_df}")
    
    # Solution 3: Use numpy's where function
    print("\nSolution 3: Using np.where()")
    fixed_array_3 = np.where(np.isnan(problematic_array), 0, problematic_array)
    print(f"Fixed array: {fixed_array_3}")
    
    return fixed_array_1, fixed_df, fixed_array_3


def generate_full_raw_table_fixed(input_df):
    """
    Fixed version of the generate_full_raw_table function.
    
    This function demonstrates how to fix the issue at line 547.
    """
    print("\n=== Fixed generate_full_raw_table Function ===")
    
    # Simulate some processing that might return a numpy array
    # (this is where the original issue likely occurs)
    processed_data = input_df.values  # This converts DataFrame to numpy array
    
    print(f"Data type after processing: {type(processed_data)}")
    print(f"Data shape: {processed_data.shape}")
    
    # ORIGINAL PROBLEMATIC CODE (commented out):
    # results_df = processed_data.fillna(0)  # ❌ This would fail!
    
    # FIXED CODE - Multiple approaches:
    
    # Approach 1: Check data type and handle accordingly
    if isinstance(processed_data, np.ndarray):
        print("Detected numpy array - using np.nan_to_num()")
        processed_data = np.nan_to_num(processed_data, nan=0.0)
        # Convert back to DataFrame if needed
        results_df = pd.DataFrame(processed_data, 
                                index=input_df.index, 
                                columns=input_df.columns)
    else:
        print("Detected pandas DataFrame - using fillna()")
        results_df = processed_data.fillna(0)
    
    print(f"Final result type: {type(results_df)}")
    return results_df


def create_actual_fix_code():
    """Creates the actual code that should be applied to fix the issue."""
    
    fix_code = '''
# Fix for anomaly_engine.py line 547
# Replace the problematic line with one of these solutions:

# ORIGINAL PROBLEMATIC CODE:
# ).fillna(0)

# SOLUTION 1: Type-safe approach (Recommended)
if isinstance(result_data, np.ndarray):
    result_data = np.nan_to_num(result_data, nan=0.0)
    # Convert back to DataFrame if the rest of the code expects DataFrame
    if hasattr(input_df, 'index') and hasattr(input_df, 'columns'):
        result_data = pd.DataFrame(result_data, index=input_df.index, columns=input_df.columns)
else:
    result_data = result_data.fillna(0)

# SOLUTION 2: Direct numpy approach (if you know it's always numpy array)
result_data = np.nan_to_num(result_data, nan=0.0)

# SOLUTION 3: Force DataFrame conversion (if you always want DataFrame output)
if isinstance(result_data, np.ndarray):
    result_data = pd.DataFrame(result_data)
result_data = result_data.fillna(0)
'''
    
    return fix_code


if __name__ == "__main__":
    # Run the demonstration
    demonstrate_problem_and_solution()
    
    # Test with sample data
    print("\n=== Testing with sample DataFrame ===")
    sample_df = pd.DataFrame({
        'feature1': [1.0, 2.0, np.nan, 4.0],
        'feature2': [np.nan, 6.0, 7.0, 8.0],
        'feature3': [9.0, np.nan, 11.0, 12.0]
    })
    
    print("Input DataFrame:")
    print(sample_df)
    
    fixed_result = generate_full_raw_table_fixed(sample_df)
    print("\nFixed result:")
    print(fixed_result)
    
    # Show the actual fix code
    print("\n" + "="*60)
    print("ACTUAL FIX CODE FOR ANOMALY_ENGINE.PY:")
    print("="*60)
    print(create_actual_fix_code())