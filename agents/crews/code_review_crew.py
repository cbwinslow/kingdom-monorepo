"""
Code Review Crew - A CrewAI configuration for automated code reviews
"""

from crewai import Agent, Task, Crew, Process
from langchain.llms import OpenAI
from typing import List, Dict


class CodeReviewCrew:
    """Crew for performing comprehensive code reviews"""
    
    def __init__(self, api_key: str = None):
        self.llm = OpenAI(temperature=0.1, api_key=api_key)
        self.agents = self._create_agents()
        self.tasks = []
    
    def _create_agents(self) -> Dict[str, Agent]:
        """Create specialized agents for code review"""
        
        return {
            'senior_reviewer': Agent(
                role='Senior Code Reviewer',
                goal='Perform thorough code review focusing on correctness and best practices',
                backstory="""You are a senior software engineer with 15+ years of experience.
                You have deep knowledge of software design patterns, clean code principles,
                and industry best practices. You provide constructive, actionable feedback.""",
                llm=self.llm,
                verbose=True,
                allow_delegation=True
            ),
            
            'security_expert': Agent(
                role='Security Specialist',
                goal='Identify security vulnerabilities and risks in the code',
                backstory="""You are a cybersecurity expert specialized in application security.
                You have extensive experience with OWASP Top 10, secure coding practices,
                and penetration testing. You catch security issues others might miss.""",
                llm=self.llm,
                verbose=True,
                allow_delegation=False
            ),
            
            'performance_analyst': Agent(
                role='Performance Analyst',
                goal='Analyze code for performance issues and optimization opportunities',
                backstory="""You are a performance engineering specialist with expertise in
                profiling, optimization, and scalability. You understand algorithmic complexity,
                resource management, and system performance characteristics.""",
                llm=self.llm,
                verbose=True,
                allow_delegation=False
            ),
            
            'test_engineer': Agent(
                role='Test Engineer',
                goal='Evaluate test coverage and quality',
                backstory="""You are a test automation expert who understands testing pyramids,
                TDD, BDD, and comprehensive test strategies. You ensure code is properly tested
                and testable.""",
                llm=self.llm,
                verbose=True,
                allow_delegation=False
            ),
            
            'tech_writer': Agent(
                role='Technical Writer',
                goal='Review documentation and code comments for clarity and completeness',
                backstory="""You are a technical writer who specializes in developer documentation.
                You ensure code is well-documented, APIs are clearly explained, and developers
                can easily understand and use the code.""",
                llm=self.llm,
                verbose=True,
                allow_delegation=False
            )
        }
    
    def review_code(self, code: str, context: str = "") -> Dict:
        """
        Perform comprehensive code review
        
        Args:
            code: The code to review
            context: Additional context about the code
            
        Returns:
            Dict containing review results from all agents
        """
        
        # Create tasks for each agent
        tasks = [
            Task(
                description=f"""Review this code for correctness, design, and best practices:
                
                Context: {context}
                
                Code:
                ```
                {code}
                ```
                
                Provide specific feedback on:
                1. Code correctness and logic
                2. Design patterns and architecture
                3. Code readability and maintainability
                4. Best practices adherence
                5. Potential improvements
                """,
                agent=self.agents['senior_reviewer'],
                expected_output="Detailed review with specific feedback and suggestions"
            ),
            
            Task(
                description=f"""Perform security analysis on this code:
                
                Code:
                ```
                {code}
                ```
                
                Check for:
                1. Input validation issues
                2. SQL injection vulnerabilities
                3. XSS vulnerabilities
                4. Authentication/authorization issues
                5. Sensitive data exposure
                6. Insecure dependencies
                """,
                agent=self.agents['security_expert'],
                expected_output="Security assessment with vulnerability report"
            ),
            
            Task(
                description=f"""Analyze this code for performance:
                
                Code:
                ```
                {code}
                ```
                
                Evaluate:
                1. Time complexity
                2. Space complexity
                3. Database query efficiency
                4. Resource usage
                5. Scalability concerns
                6. Optimization opportunities
                """,
                agent=self.agents['performance_analyst'],
                expected_output="Performance analysis with optimization suggestions"
            ),
            
            Task(
                description=f"""Review test coverage and quality:
                
                Code:
                ```
                {code}
                ```
                
                Assess:
                1. Test coverage
                2. Test quality and clarity
                3. Edge cases coverage
                4. Mock usage appropriateness
                5. Test maintainability
                """,
                agent=self.agents['test_engineer'],
                expected_output="Test quality assessment with recommendations"
            ),
            
            Task(
                description=f"""Review documentation quality:
                
                Code:
                ```
                {code}
                ```
                
                Check:
                1. Code comments clarity
                2. Function/class documentation
                3. API documentation
                4. Usage examples
                5. README completeness
                """,
                agent=self.agents['tech_writer'],
                expected_output="Documentation review with improvement suggestions"
            )
        ]
        
        # Create and run the crew
        crew = Crew(
            agents=list(self.agents.values()),
            tasks=tasks,
            process=Process.sequential,
            verbose=True
        )
        
        result = crew.kickoff()
        return result
    
    def review_pull_request(self, pr_data: Dict) -> Dict:
        """
        Review an entire pull request
        
        Args:
            pr_data: Dictionary containing PR information
                - title: PR title
                - description: PR description
                - files: List of changed files
                - diff: Git diff
                
        Returns:
            Comprehensive PR review
        """
        
        context = f"""
        Pull Request: {pr_data.get('title', 'N/A')}
        Description: {pr_data.get('description', 'N/A')}
        Files Changed: {len(pr_data.get('files', []))}
        """
        
        return self.review_code(pr_data.get('diff', ''), context)


def main():
    """Example usage"""
    crew = CodeReviewCrew()
    
    # Example code to review
    example_code = """
    def process_user_data(user_input):
        # Process user data
        query = f"SELECT * FROM users WHERE name = '{user_input}'"
        result = db.execute(query)
        return result
    """
    
    review = crew.review_code(
        code=example_code,
        context="This is a user data processing function"
    )
    
    print("Code Review Results:")
    print(review)


if __name__ == "__main__":
    main()
